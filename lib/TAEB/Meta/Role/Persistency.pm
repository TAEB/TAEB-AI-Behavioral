#!/usr/bin/env perl
package TAEB::Meta::Role::Persistency;
use Moose::Role;
use Storable;

requires 'persistent_file';

sub save_state {
    my $self = shift;
    my $file = $self->persistent_file;
    return unless defined $file;

    my $state = {};

    my @attrs = $self->meta->compute_all_applicable_attributes;
    push @attrs, $self->meta->compute_all_applicable_class_attributes
        if $self->meta->can('compute_all_applicable_class_attributes');

    for my $attr (@attrs) {
        next unless $attr->does('TAEB::Persistent');

        my $name   = $attr->name;
        my $reader = $attr->get_read_method_ref;
        $state->{$name} = $reader->($self);
    }

    Storable::nstore($state, $file);
}

sub destroy_saved_state {
    my $self = shift;
    my $file = $self->persistent_file;
    unlink $file if defined $file;
}

no Moose::Role;

1;


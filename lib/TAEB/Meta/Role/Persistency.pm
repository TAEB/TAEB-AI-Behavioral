#!/usr/bin/env perl
package TAEB::Meta::Role::Persistency;
use Moose::Role;
use Storable;

requires 'persistent_file';

has persistent_data => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $file = $self->persistent_file;
        return {} unless defined $file && -r $file;

        TAEB->info("Loading persistency data.");
        return eval { Storable::retrieve($file) } || {};
    },
);

sub save_state {
    my $self = shift;
    my $file = $self->persistent_file;
    return unless defined $file;

    my $state = {};

    for my $attr ($self->meta->compute_all_applicable_attributes) {
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


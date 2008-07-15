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
        return eval { Storable::retrieve(shift->persistent_file) } || {};
    },
);

sub save_state {
    my $self = shift;
    my $state = {};

    for my $attr ($self->meta->compute_all_applicable_attributes) {
        next unless $attr->does('TAEB::Persistent');

        my $name   = $attr->name;
        my $reader = $attr->get_read_method_ref;
        $state->{$name} = $reader->($self);
    }

    Storable::nstore($state, $self->persistent_file);
}

no Moose::Role;

1;


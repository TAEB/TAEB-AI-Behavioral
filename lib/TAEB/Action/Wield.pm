#!/usr/bin/env perl
package TAEB::Action::Wield;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "w";

has weapon => (
    isa      => 'TAEB::World::Item | Str',
    required => 1,
);

sub to_wield {
    my $self = shift;
    return $self->weapon->slot if blessed $self->weapon;
    return $self->weapon;
}

sub respond_wield_what { shift->to_wield }

sub done {
    my $self = shift;
    # XXX: we need to track TAEB's weapon
}

make_immutable;
no Moose;

1;


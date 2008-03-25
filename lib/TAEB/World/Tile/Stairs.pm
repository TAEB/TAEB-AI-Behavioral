#!/usr/bin/env perl
package TAEB::World::Tile::Stairs;
use TAEB::OO;
extends 'TAEB::World::Tile';

has other_side => (
    isa      => 'TAEB::World::Tile',
    weak_ref => 1,
);

sub unblessed {
    my $self = shift;
    $self->level->remove_exit($self);
}

sub reblessed {
    my $self = shift;
    $self->level->add_exit($self);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


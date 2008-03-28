#!/usr/bin/env perl
package TAEB::World::Tile::Stairs;
use TAEB::OO;
extends 'TAEB::World::Tile';

has other_side => (
    isa      => 'TAEB::World::Tile',
    weak_ref => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


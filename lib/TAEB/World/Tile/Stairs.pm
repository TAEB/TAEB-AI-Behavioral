#!/usr/bin/env perl
package TAEB::World::Tile::Stairs;
use Moose;
extends 'TAEB::World::Tile';

has other_side => (
    is       => 'rw',
    isa      => 'TAEB::World::Tile::Stairs',
    weak_ref => 1,
);

has '+type' => (
    default => 'stairs',
);

make_immutable;

1;


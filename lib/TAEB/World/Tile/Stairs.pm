#!/usr/bin/env perl
package TAEB::World::Tile::Stairs;
use TAEB::OO;
extends 'TAEB::World::Tile';

has other_side => (
    isa      => 'TAEB::World::Tile::Stairs',
    weak_ref => 1,
);

has '+type' => (
    default => 'stairs',
);

make_immutable;
no Moose;

1;


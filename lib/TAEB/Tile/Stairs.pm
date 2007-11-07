#!/usr/bin/env perl
package TAEB::Tile::Stairs;
use Moose;
extends 'TAEB::Tile';

has other_side => (
    is => 'rw',
    isa => 'TAEB::Tile::Stairs',
);

1;


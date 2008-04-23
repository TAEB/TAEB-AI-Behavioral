#!/usr/bin/env perl
package TAEB::World::Tile::Stairsup;
use TAEB::OO;
extends 'TAEB::World::Tile::Stairs';

has '+type' => (
    default => 'stairsup',
);

has '+glyph' => (
    default => '<',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


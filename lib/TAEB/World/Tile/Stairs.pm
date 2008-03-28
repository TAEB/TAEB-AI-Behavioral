#!/usr/bin/env perl
package TAEB::World::Tile::Stairs;
use TAEB::OO;
extends 'TAEB::World::Tile';

has other_side => (
    isa      => 'TAEB::World::Tile',
    weak_ref => 1,
);

sub traverse_command { shift->floor_glyph }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


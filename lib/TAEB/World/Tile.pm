#!/usr/bin/env perl
package TAEB::Tile;
use Moose;

has level => (
    is       => 'rw',
    isa      => 'TAEB::Level',
    weak_ref => 1,
    required => 1,
);

has room => (
    is       => 'rw',
    isa      => 'TAEB::Room',
    weak_ref => 1,
);

enum TileType => TAEB::Util::tile_types;

has type => (
    is => 'rw',
    isa => 'TileType',
);

1;


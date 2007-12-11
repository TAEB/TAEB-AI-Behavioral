#!/usr/bin/env perl
package TAEB::Tile;
use Moose;
use Moose::Util::TypeConstraints 'enum';

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

enum TileType => TAEB::Util::tile_types();

has type => (
    is      => 'rw',
    isa     => 'TileType',
    default => 'obscured',
);

1;


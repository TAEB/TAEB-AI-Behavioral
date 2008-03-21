#!/usr/bin/env perl
package TAEB::World::Tile::Closeddoor;
use TAEB::OO;
extends 'TAEB::World::Tile';

has locked => (
    isa     => 'DoorState',
    default => 'unknown',
);

has '+type' => (
    default => 'closeddoor',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


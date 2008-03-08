#!/usr/bin/env perl
package TAEB::World::Tile::Closeddoor;
use Moose;
extends 'TAEB::World::Tile';

enum DoorState => qw(locked unlocked unknown);
has locked => (
    is  => 'rw',
    isa => 'DoorState',
);

has '+type' => (
    default => 'closeddoor',
);

make_immutable;

1;


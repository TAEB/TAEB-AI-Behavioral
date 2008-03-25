#!/usr/bin/env perl
package TAEB::World::Tile::Sink;
use TAEB::OO;
extends 'TAEB::World::Tile';

has got_ring => (
    isa     => 'Bool',
    default => 0,
);

has got_foocubus => (
    isa     => 'Bool',
    default => 0,
);

has got_pudding => (
    isa     => 'Bool',
    default => 0,
);

has '+type' => (
    default => 'sink',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


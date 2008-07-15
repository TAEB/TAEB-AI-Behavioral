#!/usr/bin/env perl
package TAEB::World::Tile::Opendoor;
use TAEB::OO;
extends 'TAEB::World::Tile::Door';

has '+type' => (
    default => 'opendoor',
);

use constant locked => 0;

__PACKAGE__->meta->make_immutable;
no Moose;

1;


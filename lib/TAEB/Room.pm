#!/usr/bin/env perl
package TAEB::Room;
use Moose;

has tiles => (
    is       => 'rw',
    isa      => 'ArrayRef', # XXX: does Moose support [TAEB::Tile] yet
    weak_ref => 1, # weak because levels contain all the tiles
);

has level => (
    is       => 'rw',
    isa      => 'TAEB::Level',
    weak_ref => 1,
);

1;


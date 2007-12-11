#!/usr/bin/env perl
package TAEB::World::Level;
use Moose;

has tiles => (
    is  => 'rw',
    isa => 'ArrayRef[ArrayRef[TAEB::World::Tile]]',
);

has branch => (
    is       => 'rw',
    isa      => 'TAEB::World::Branch',
    weak_ref => 1,
);

has z => (
    is  => 'rw',
    isa => 'Int',
);

1;


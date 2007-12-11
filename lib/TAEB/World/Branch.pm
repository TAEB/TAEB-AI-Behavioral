#!/usr/bin/env perl
package TAEB::World::Branch;
use Moose;

has levels => (
    is  => 'rw',
    isa => 'ArrayRef[TAEB::World::Level]',
);

has dungeon => (
    is       => 'rw',
    isa      => 'TAEB::World::Dungeon',
    weak_ref => 1,
);

1;


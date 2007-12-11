#!/usr/bin/env perl
package TAEB::World::Dungeon;
use Moose;

has branches => (
    is  => 'rw',
    isa => 'ArrayRef[TAEB::World::Branch]',
);

has current_level => (
    is => 'rw',
    isa => 'TAEB::World::Level',
);

1;


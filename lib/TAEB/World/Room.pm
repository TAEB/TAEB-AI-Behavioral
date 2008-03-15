#!/usr/bin/env perl
package TAEB::World::Room;
use TAEB::OO;

has tiles => (
    isa      => 'ArrayRef[TAEB::World::Room]',
    weak_ref => 1, # weak because levels contain all the tiles
);

has level => (
    isa      => 'TAEB::World::Level',
    weak_ref => 1,
);

make_immutable;
no Moose;

1;


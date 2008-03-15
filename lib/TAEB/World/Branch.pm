#!/usr/bin/env perl
package TAEB::World::Branch;
use TAEB::OO;

has name => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has levels => (
    is  => 'rw',
    isa => 'ArrayRef[TAEB::World::Level]',
);

has dungeon => (
    is       => 'rw',
    isa      => 'TAEB::World::Dungeon',
    weak_ref => 1,
);

make_immutable;
no Moose;

1;


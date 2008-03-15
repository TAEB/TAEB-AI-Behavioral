#!/usr/bin/env perl
package TAEB::World::Branch;
use TAEB::OO;

has name => (
    isa      => 'Str',
    required => 1,
);

has levels => (
    isa => 'ArrayRef[TAEB::World::Level]',
);

has dungeon => (
    isa      => 'TAEB::World::Dungeon',
    weak_ref => 1,
);

make_immutable;
no Moose;

1;


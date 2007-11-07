#!/usr/bin/env perl
package TAEB::Branch;
use Moose;

has levels => (
    is  => 'rw',
    isa => 'ArrayRef', # XXX: does Moose support [TAEB::Level] yet
);

has dungeon => (
    is       => 'rw',
    isa      => 'TAEB::Dungeon',
    weak_ref => 1,
);

1;


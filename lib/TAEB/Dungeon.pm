#!/usr/bin/env perl
package TAEB::Dungeon;
use Moose;

has branches => (
    is  => 'rw',
    isa => 'ArrayRef', # XXX: does Moose support [TAEB::Branch] yet
);

1;


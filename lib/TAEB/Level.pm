#!/usr/bin/env perl
package TAEB::Level;
use Moose;

has tiles => (
    is  => 'rw',
    isa => 'ArrayRef', # XXX: does Moose support [[Taeb::Tile]] yet
);

has branch => (
    is       => 'rw',
    isa      => 'TAEB::Branch',
    weak_ref => 1,
);

1;


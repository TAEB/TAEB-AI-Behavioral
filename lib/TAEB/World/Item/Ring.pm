#!/usr/bin/env perl
package TAEB::World::Item::Ring;
use Moose;
extends 'TAEB::World::Item';

has class => (
    is      => 'ro',
    isa     => 'Str',
    default => 'ring',
);

1;


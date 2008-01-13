#!/usr/bin/env perl
package TAEB::World::Item::Food;
use Moose;
extends 'TAEB::World::Item';

has class => (
    is      => 'ro',
    isa     => 'Str',
    default => 'food',
);

1;


#!/usr/bin/env perl
package TAEB::World::Item::Armor;
use Moose;
extends 'TAEB::World::Item';

has class => (
    is      => 'ro',
    isa     => 'Str',
    default => 'armor',
);

1;


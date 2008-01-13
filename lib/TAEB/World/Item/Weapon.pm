#!/usr/bin/env perl
package TAEB::World::Item::Weapon;
use Moose;
extends 'TAEB::World::Item';

has class => (
    is      => 'ro',
    isa     => 'Str',
    default => 'weapon',
);

1;


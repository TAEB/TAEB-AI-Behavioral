#!/usr/bin/env perl
package TAEB::World::Item::Potion;
use Moose;
extends 'TAEB::World::Item';

has class => (
    is      => 'ro',
    isa     => 'Str',
    default => 'potion',
);

1;


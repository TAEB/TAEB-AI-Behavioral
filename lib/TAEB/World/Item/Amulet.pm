#!/usr/bin/env perl
package TAEB::World::Item::Amulet;
use Moose;
extends 'TAEB::World::Item';

has class => (
    is      => 'ro',
    isa     => 'Str',
    default => 'amulet',
);

1;


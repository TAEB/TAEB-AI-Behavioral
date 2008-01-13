#!/usr/bin/env perl
package TAEB::World::Item::Wand;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Chargeable';

has class => (
    is      => 'ro',
    isa     => 'Str',
    default => 'wand',
);

1;


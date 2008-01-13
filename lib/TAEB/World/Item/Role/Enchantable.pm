#!/usr/bin/env perl
package TAEB::World::Item::Role::Enchantable;
use Moose::Role;

has enchantment => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

1;


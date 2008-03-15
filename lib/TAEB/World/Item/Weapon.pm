#!/usr/bin/env perl
package TAEB::World::Item::Weapon;
use TAEB::OO;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Erodable';

has '+class' => (
    default => 'weapon',
);

has is_poisoned => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

make_immutable;

1;


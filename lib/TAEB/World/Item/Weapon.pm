#!/usr/bin/env perl
package TAEB::World::Item::Weapon;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Erodable';

has '+class' => (
    default => 'weapon',
);

has is_poisoned => (
);

1;


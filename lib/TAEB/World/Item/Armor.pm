#!/usr/bin/env perl
package TAEB::World::Item::Armor;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Erodable';
with 'TAEB::World::Item::Role::Wearable';

has '+class' => (
    default => 'armor',
);

make_immutable;

1;


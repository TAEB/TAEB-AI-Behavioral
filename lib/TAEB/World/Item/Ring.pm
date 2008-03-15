#!/usr/bin/env perl
package TAEB::World::Item::Ring;
use TAEB::OO;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Wearable';

has '+class' => (
    default => 'ring',
);

make_immutable;
no Moose;

1;


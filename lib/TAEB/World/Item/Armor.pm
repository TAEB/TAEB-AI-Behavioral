#!/usr/bin/env perl
package TAEB::World::Item::Armor;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Wearable';

has '+class' => (
    default => 'armor',
);

1;


#!/usr/bin/env perl
package TAEB::World::Item::Amulet;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Wearable';

has '+class' => (
    default => 'amulet',
);

1;


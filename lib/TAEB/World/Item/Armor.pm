#!/usr/bin/env perl
package TAEB::World::Item::Armor;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'armor',
);

1;


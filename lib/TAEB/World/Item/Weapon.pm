#!/usr/bin/env perl
package TAEB::World::Item::Weapon;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'weapon',
);

has is_poisoned => (
);

1;


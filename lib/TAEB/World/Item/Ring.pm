#!/usr/bin/env perl
package TAEB::World::Item::Ring;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Wearable';

has '+class' => (
    default => 'ring',
);

1;


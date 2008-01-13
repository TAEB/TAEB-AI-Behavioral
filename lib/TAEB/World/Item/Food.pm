#!/usr/bin/env perl
package TAEB::World::Item::Food;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'food',
);

1;


#!/usr/bin/env perl
package TAEB::World::Item::Potion;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'potion',
);

1;


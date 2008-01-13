#!/usr/bin/env perl
package TAEB::World::Item::Ring;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'ring',
);

1;


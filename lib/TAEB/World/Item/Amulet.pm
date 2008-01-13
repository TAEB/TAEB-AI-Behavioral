#!/usr/bin/env perl
package TAEB::World::Item::Amulet;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'amulet',
);

1;


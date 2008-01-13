#!/usr/bin/env perl
package TAEB::World::Item::Other;
use Moose;
extends 'TAEB::World::Item';
# for instance, iron balls, chains, statues, etc

has '+class' => (
    default => 'other',
);

1;


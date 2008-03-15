#!/usr/bin/env perl
package TAEB::World::Item::Other;
use TAEB::OO;
extends 'TAEB::World::Item';
# for instance, iron balls, chains, statues, etc

has '+class' => (
    default => 'other',
);

has is_chained_to_you => (
    isa     => 'Bool',
    default => 0,
);

make_immutable;
no Moose;

1;


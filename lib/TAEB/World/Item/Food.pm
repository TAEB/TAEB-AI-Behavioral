#!/usr/bin/env perl
package TAEB::World::Item::Food;
use TAEB::OO;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'food',
);

has is_partly_eaten => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has is_laid_by_you => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

make_immutable;
no Moose;

1;


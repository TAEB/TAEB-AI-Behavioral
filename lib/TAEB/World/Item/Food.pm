#!/usr/bin/env perl
package TAEB::World::Item::Food;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'food',
);

has is_partly_eaten => (
);

has is_laid_by_you => (
);

1;


#!/usr/bin/env perl
package TAEB::World::Item::Gem;
use TAEB::OO;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'gem',
);

make_immutable;

1;


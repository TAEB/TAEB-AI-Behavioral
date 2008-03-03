#!/usr/bin/env perl
package TAEB::World::Item::Scroll;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'scroll',
);

make_immutable;

1;


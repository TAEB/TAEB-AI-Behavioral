#!/usr/bin/env perl
package TAEB::World::Item::Scroll;
use TAEB::OO;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'scroll',
);

make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::World::Item::Wand;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Chargeable';
with 'TAEB::World::Item::Role::Erodable';

has '+class' => (
    default => 'wand',
);

make_immutable;

1;


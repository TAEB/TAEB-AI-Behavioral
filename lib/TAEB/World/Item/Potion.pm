#!/usr/bin/env perl
package TAEB::World::Item::Potion;
use TAEB::OO;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Lightable';

has '+class' => (
    default => 'potion',
);

has is_diluted => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

make_immutable;

1;


#!/usr/bin/env perl
package TAEB::World::Item::Tool;
use TAEB::OO;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Chargeable';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Erodable';
with 'TAEB::World::Item::Role::Lightable';

has '+class' => (
    default => 'tool',
);

has is_partly_used => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has candles_attached => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

make_immutable;
no Moose;

1;


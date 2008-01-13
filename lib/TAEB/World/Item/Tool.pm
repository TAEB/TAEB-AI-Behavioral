#!/usr/bin/env perl
package TAEB::World::Item::Tool;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Chargeable';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Erodable';
with 'TAEB::World::Item::Role::Lightable';

has '+class' => (
    default => 'tool',
);

has is_partly_used => (
);

has candles_attached => (
);

1;


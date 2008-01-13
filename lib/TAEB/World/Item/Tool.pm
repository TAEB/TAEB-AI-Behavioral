#!/usr/bin/env perl
package TAEB::World::Item::Tool;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Chargeable';

has '+class' => (
    default => 'tool',
);

has is_partly_used => (
);

has candles_attached => (
);

1;


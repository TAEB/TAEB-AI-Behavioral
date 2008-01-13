#!/usr/bin/env perl
package TAEB::World::Item::Tool;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Chargeable';

has '+class' => (
    default => 'tool',
);

1;


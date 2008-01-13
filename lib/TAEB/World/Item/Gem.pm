#!/usr/bin/env perl
package TAEB::World::Item::Gem;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'gem',
);

1;


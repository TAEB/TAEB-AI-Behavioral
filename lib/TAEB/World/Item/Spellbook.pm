#!/usr/bin/env perl
package TAEB::World::Item::Spellbook;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'spellbook',
);

1;


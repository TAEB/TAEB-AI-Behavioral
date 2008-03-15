#!/usr/bin/env perl
package TAEB::World::Item::Spellbook;
use TAEB::OO;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'spellbook',
);

make_immutable;
no Moose;

1;


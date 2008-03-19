#!/usr/bin/env perl
package TAEB::World::Item::Wand;
use TAEB::OO 'install_spoilers';
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Chargeable';
with 'TAEB::World::Item::Role::Erodable';

has '+class' => (
    default => 'wand',
);

install_spoilers(qw/maxcharges type/);

make_immutable;
no Moose;

1;


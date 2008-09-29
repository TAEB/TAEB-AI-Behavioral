#!/usr/bin/env perl
package TAEB::World::Item::Armor;
use TAEB::OO;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Erodable';
with 'TAEB::World::Item::Role::Wearable';

has '+class' => (
    default => 'armor',
);

__PACKAGE__->install_spoilers(qw/ac mc/);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


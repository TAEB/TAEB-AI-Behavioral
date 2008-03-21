#!/usr/bin/env perl
package TAEB::World::Item::Amulet;
use TAEB::OO;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Wearable';

has '+class' => (
    default => 'amulet',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


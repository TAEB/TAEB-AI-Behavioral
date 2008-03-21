#!/usr/bin/env perl
package TAEB::World::Item::Ring;
use TAEB::OO 'install_spoilers';
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Wearable';

has '+class' => (
    default => 'ring',
);

install_spoilers(qw/chargeable/);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


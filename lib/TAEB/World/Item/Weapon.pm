#!/usr/bin/env perl
package TAEB::World::Item::Weapon;
use TAEB::OO 'install_spoilers';
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Erodable';

has '+class' => (
    default => 'weapon',
);

has is_poisoned => (
    isa     => 'Bool',
    default => 0,
);

install_spoilers(qw/sdam ldam tohit hands/);
__PACKAGE__->meta->make_immutable;
no Moose;

1;


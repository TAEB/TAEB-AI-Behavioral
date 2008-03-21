#!/usr/bin/env perl
package TAEB::World::Item::Spellbook;
use TAEB::OO 'install_spoilers';
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Writable';

has '+class' => (
    default => 'spellbook',
);

install_spoilers(qw/level read marker emergency role/);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


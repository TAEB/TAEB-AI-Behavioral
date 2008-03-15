#!/usr/bin/env perl
package TAEB::World::Item::Tool;
use TAEB::OO 'install_spoilers';
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Chargeable';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Erodable';
with 'TAEB::World::Item::Role::Lightable';

has '+class' => (
    default => 'tool',
);

has is_partly_used => (
    isa     => 'Bool',
    default => 0,
);

has candles_attached => (
    isa     => 'Int',
    default => 0,
);

install_spoilers(qw/charge/);
make_immutable;
no Moose;

1;


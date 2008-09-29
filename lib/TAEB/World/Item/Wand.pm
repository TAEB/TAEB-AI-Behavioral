#!/usr/bin/env perl
package TAEB::World::Item::Wand;
use TAEB::OO;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Chargeable';
with 'TAEB::World::Item::Role::Erodable';

has '+class' => (
    default => 'wand',
);

__PACKAGE__->install_spoilers(qw/maxcharges type/);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


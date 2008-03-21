#!/usr/bin/env perl
package TAEB::World::Item::Potion;
use TAEB::OO;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Lightable';

has '+class' => (
    default => 'potion',
);

has is_diluted => (
    isa     => 'Bool',
    default => 0,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


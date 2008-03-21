#!/usr/bin/env perl
package TAEB::World::Item::Gold;
use TAEB::OO;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'gold',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


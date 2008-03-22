#!/usr/bin/env perl
package TAEB::World::Item::Role::Wearable;
use Moose::Role;

has is_wearing => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

no Moose::Role;

1;


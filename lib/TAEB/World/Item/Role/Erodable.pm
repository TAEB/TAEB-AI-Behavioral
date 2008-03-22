#!/usr/bin/env perl
package TAEB::World::Item::Role::Erodable;
use Moose::Role;

has erosion1 => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has erosion2 => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has is_fooproof => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

no Moose::Role;

1;


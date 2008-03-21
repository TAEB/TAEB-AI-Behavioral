#!/usr/bin/env perl
package TAEB::World::Item::Food;
use TAEB::OO 'install_spoilers';
extends 'TAEB::World::Item';

has '+class' => (
    default => 'food',
);

has is_partly_eaten => (
    isa     => 'Bool',
    default => 0,
);

has is_laid_by_you => (
    isa     => 'Bool',
    default => 0,
);

install_spoilers(qw/nutrition time/);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


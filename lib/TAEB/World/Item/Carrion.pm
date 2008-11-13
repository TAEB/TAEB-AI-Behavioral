#!/usr/bin/env perl
package TAEB::World::Item::Carrion;
use TAEB::OO;
use TAEB::Spoilers::Monster;
extends 'TAEB::World::Item::Food';

has is_forced_verboten => (
    isa     => 'Bool',
    default => 0,
);

has estimated_date => (
    isa     => 'Bool',
    default => 0,
);

sub estimate_age { TAEB->turn - shift->estimated_date; }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


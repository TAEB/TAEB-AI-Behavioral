#!/usr/bin/env perl
package TAEB::Action::Apply;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "a";

has item => (
    is       => 'rw',
    isa      => 'TAEB::World::Item',
    required => 1,
);

sub respond_apply_what { shift->item->slot }

make_immutable;
no Moose;

1;


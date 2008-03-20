#!/usr/bin/perl
package TAEB::Action::Wear;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "W";

has item => (
    isa      => 'TAEB::World::Item',
    required => 1,
);

sub respond_wear_what { shift->item->slot }

make_immutable;
no Moose;

1;


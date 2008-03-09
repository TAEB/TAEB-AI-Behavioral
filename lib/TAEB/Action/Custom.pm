#!/usr/bin/env perl
package TAEB::Action::Custom;
use Moose;
extends 'TAEB::Action';

has string => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub command { shift->string }

1;


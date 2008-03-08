#!/usr/bin/env perl
package TAEB::Action::Kick;
use Moose;
extends 'TAEB::Action';

# ctrl-D
use constant command => chr(4);

has direction => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub respond_what_direction { shift->direction }

1;


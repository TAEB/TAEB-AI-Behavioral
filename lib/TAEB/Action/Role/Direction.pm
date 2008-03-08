#!/usr/bin/env perl
package TAEB::Action::Role::Direction;
use Moose::Role;

has direction => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub respond_what_direction { shift->direction }

1;


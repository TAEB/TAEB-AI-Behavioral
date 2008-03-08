#!/usr/bin/env perl
package TAEB::Action::Throw;
use Moose;
extends 'TAEB::Action';

use constant commands => 't';

has item => (
    is       => 'rw',
    isa      => 'TAEB::World::Item',
    required => 1,
);

has direction => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub respond_throw_what { shift->item->slot }
sub respond_what_direction { shift->direction }

1;


#!/usr/bin/env perl
package TAEB::Action::Cast;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => 'Z';

has spell => (
    is       => 'rw',
    isa      => 'TAEB::Knowledge::Spell',
    required => 1,
);

has direction => (
    is  => 'rw',
    isa => 'Str',
);

sub respond_what_direction { shift->direction }
sub respond_which_spell { shift->spell->slot }

make_immutable;
no Moose;

1;


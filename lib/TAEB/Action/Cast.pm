#!/usr/bin/env perl
package TAEB::Action::Cast;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

use constant command => 'Z';

has spell => (
    isa      => 'TAEB::Knowledge::Spell',
    required => 1,
);

sub respond_which_spell { shift->spell->slot }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


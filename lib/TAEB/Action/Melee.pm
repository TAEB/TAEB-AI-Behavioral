#!/usr/bin/env perl
package TAEB::Action::Melee;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

# sadly, Melee doesn't give an "In what direction?" message
sub command {
    'F' . shift->direction
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;



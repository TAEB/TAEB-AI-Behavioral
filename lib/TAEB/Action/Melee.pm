#!/usr/bin/env perl
package TAEB::Action::Melee;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

# sadly, Melee doesn't give an "In what direction?" message
sub command {
    'F' . shift->direction
}

make_immutable;

1;



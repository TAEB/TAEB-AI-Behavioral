#!/usr/bin/env perl
package TAEB::Action::Melee;
use Moose;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

use constant command => 'F';

make_immutable;

1;



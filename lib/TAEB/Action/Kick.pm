#!/usr/bin/env perl
package TAEB::Action::Kick;
use Moose;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

# ctrl-D
use constant command => chr(4);

1;


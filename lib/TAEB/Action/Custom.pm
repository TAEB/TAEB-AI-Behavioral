#!/usr/bin/env perl
package TAEB::Action::Custom;
use TAEB::OO;
extends 'TAEB::Action';

has string => (
    isa      => 'Str',
    required => 1,
);

sub command { shift->string }

1;


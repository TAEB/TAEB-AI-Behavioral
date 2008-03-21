#!/usr/bin/env perl
package TAEB::Action::Kick;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

# ctrl-D
use constant command => chr(4);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


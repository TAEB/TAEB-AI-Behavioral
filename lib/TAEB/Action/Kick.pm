#!/usr/bin/env perl
package TAEB::Action::Kick;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

has '+direction' => (
    required => 1,
);

# ctrl-D
use constant command => chr(4);

# sorry sir!
sub respond_buy_door { 'y' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


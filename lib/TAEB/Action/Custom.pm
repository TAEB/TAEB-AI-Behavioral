#!/usr/bin/env perl
package TAEB::Action::Custom;
use TAEB::OO;
extends 'TAEB::Action';

has string => (
    traits   => [qw/TAEB::Provided/],
    isa      => 'Str',
    required => 1,
);

sub command { shift->string }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


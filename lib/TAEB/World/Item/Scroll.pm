#!/usr/bin/env perl
package TAEB::World::Item::Scroll;
use Moose;
extends 'TAEB::World::Item';

has class => (
    is      => 'ro',
    isa     => 'Str',
    default => 'scroll',
);

1;


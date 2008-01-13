#!/usr/bin/env perl
package TAEB::World::Item::Book;
use Moose;
extends 'TAEB::World::Item';

has class => (
    is      => 'ro',
    isa     => 'Str',
    default => 'book',
);

1;


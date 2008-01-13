#!/usr/bin/env perl
package TAEB::World::Item::Book;
use Moose;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'book',
);

1;


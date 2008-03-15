#!/usr/bin/env perl
package TAEB::World::Item::Gem;
use TAEB::OO 'install_spoilers';
extends 'TAEB::World::Item';

has '+class' => (
    default => 'gem',
);

install_spoilers(qw/engrave/);

make_immutable;
no Moose;

1;


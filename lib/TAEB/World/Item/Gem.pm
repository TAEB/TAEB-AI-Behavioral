#!/usr/bin/env perl
package TAEB::World::Item::Gem;
use TAEB::OO;
extends 'TAEB::World::Item';

has '+class' => (
    default => 'gem',
);

__PACKAGE__->install_spoilers(qw/engrave/);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


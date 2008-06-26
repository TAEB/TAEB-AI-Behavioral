#!/usr/bin/env perl
package TAEB::World::Level::Minetown;
use TAEB::OO;
extends 'TAEB::World::Level';

__PACKAGE__->meta->add_method("is_$_" => sub { 0 })
    for (grep { $_ ne 'minetown' } @TAEB::World::Level::special_levels);

sub is_minetown { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


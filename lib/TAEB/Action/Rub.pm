#!/usr/bin/env perl
package TAEB::Action::Rub;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Item';

use constant command => "#rub\n";

has '+item' => {
    isa      => 'TAEB::World::Item',
    required => 1,
}

has against => {
    isa      => 'TAEB::World::Item',
    required => 0,
    traits   => [qw/TAEB::Provided/],
}

sub respond_rub_what { shift->item->slot }

sub respond_rub_on_what { shift->item->slot }

__PACKAGE_->meta->make_immutable;
no Moose;

1;


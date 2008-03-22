#!/usr/bin/env perl
package TAEB::Action::Zap;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';
with 'TAEB::Action::Role::Item';

use constant command => 'z';

has '+item' => (
    required => 1,
);

sub respond_zap_what { shift->item->slot }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


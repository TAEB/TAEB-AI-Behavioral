#!/usr/bin/perl
package TAEB::Action::Wear;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Item';

use constant command => "W";

has item => (
    isa      => 'TAEB::World::Item',
    required => 1,
);

sub respond_wear_what { shift->item->slot }

sub done {
    my $self = shift;
    $self->item->is_wearing(1);
    # XXX: needs to track where it is worn as well
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


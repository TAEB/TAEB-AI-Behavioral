#!/usr/bin/perl
package TAEB::Action::Puton;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Item';

use constant command => "P";

has item => (
    traits   => [qw/TAEB::Provided/],
    isa      => 'TAEB::World::Item',
    required => 1,
);

sub respond_put_on_what { shift->item->slot }

sub respond_which_finger { 'l' }

sub done {
    my $self = shift;
    $self->item->is_wearing(1);
    # XXX: needs to track where it is worn as well
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


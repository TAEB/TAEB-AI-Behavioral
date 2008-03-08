#!/usr/bin/env perl
package TAEB::Action::Quaff;
use Moose;
extends 'TAEB::Action';

use constant command => "q";

has from => (
    is       => 'rw',
    isa      => 'TAEB::World::Item | Str',
    required => 1,
);

sub respond_drink_from {
    my $self = shift;
    my $msg  = shift;
    my $from = shift;

    return 'n' if blessed $self->from;
    return 'y' if $from eq $self->from;
    return 'n';
}

sub respond_drink_what {
    my $self = shift;
    return $self->from->slot if blessed($self->from);

    TAEB->error("Unable to drink from '" . $self->into . "'. Sending escape, but I doubt this will work.");
    return "\e";
}

make_immutable;

1;


#!/usr/bin/env perl
package TAEB::Action::Dip;
use Moose;
extends 'TAEB::Action';

use constant command => "#dip\n";

has item => (
    is       => 'rw',
    isa      => 'TAEB::World::Item',
    required => 1,
);

has into => (
    is      => 'rw',
    isa     => 'TAEB::World::Item | Str',
    default => 'fountain',
);

sub respond_dip_what { shift->item->slot }

sub respond_dip_into_fountain { shift->into eq 'fountain' ? 'y' : 'n' }

sub respond_dip_into {
    my $self = shift;
    return $self->into->slot if blessed($self->into);

    TAEB->error("Unable to dip into '" . $self->into . "'. Sending escape, but I doubt this will work.");
    return "\e";
}

1;


#!/usr/bin/env perl
package TAEB::Action::Move;
use Moose;
extends 'TAEB::Action';

has path => (
    is  => 'rw',
    isa => 'TAEB::World::Path',
);

has direction => (
    is  => 'rw',
    isa => 'Str',
);

sub BUILD {
    my $self = shift;

    confess "You must specify a path or direction to the Move action."
        unless $self->path || $self->direction;
}

sub directions {
    my $self = shift;
    return $self->direction || $self->path->path;
}

sub command {
    my $self = shift;

    # XXX: this will break when we have something like stepping onto a teleport
    # trap with TC (intentionally)
    return substr($self->directions, 0, 1);
}

1;


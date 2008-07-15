#!/usr/bin/env perl
package TAEB::World::Tile::Door;
use TAEB::OO;
extends 'TAEB::World::Tile';

has state => (
    isa => 'DoorState',
);

sub locked {
    my $self = shift;
    $self->state && $self->state eq 'locked';
}

sub unlocked {
    my $self = shift;
    $self->state && $self->state eq 'unlocked';
}

sub blocked_door {
    my $self = shift;
    my $blocked_door = 0;

    $self->each_orthogonal( sub {
        my $tile = shift;
        return unless $tile->glyph eq '0' || $tile->type eq 'trap';
        $blocked_door = 1;
    });

    return $blocked_door;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


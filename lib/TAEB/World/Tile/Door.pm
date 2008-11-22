#!/usr/bin/env perl
package TAEB::World::Tile::Door;
use TAEB::OO;
use List::Util qw/min/;
extends 'TAEB::World::Tile';

has state => (
    isa => 'TAEB::Type::DoorState',
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
    my $orthogonal_tiles = 0;

    $self->each_orthogonal( sub {
        my $tile = shift;
        return if $tile->type eq 'rock' || $tile->type eq 'unexplored';
        $orthogonal_tiles++;
        return if $tile->is_walkable && $tile->type ne 'trap';
        $blocked_door++;
    });

    # all visible orthogonal tiles to the door must be unblocked, and if both
    # the inside and the outside of the door are visible, they must both be
    # unblocked
    return $blocked_door >= min($orthogonal_tiles, 3);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


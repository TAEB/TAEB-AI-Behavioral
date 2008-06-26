#!/usr/bin/env perl
package TAEB::World::Tile::Closeddoor;
use TAEB::OO;
extends 'TAEB::World::Tile';
use TAEB::Util ':colors';

has state => (
    isa => 'DoorState',
);

has '+type' => (
    default => 'closeddoor',
);

has is_shop => (
    isa     => 'Bool',
    default => 0,
);

sub debug_color {
    my $self = shift;

    if ($self->is_shop) {
        return Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_RED);
    }
    elsif ($self->locked) {
        return Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_BROWN);
    }
    elsif ($self->unlocked) {
        return Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_GREEN);
    }

    return;
}

sub locked {
    my $self = shift;
    $self->state && $self->state eq 'locked';
}

sub unlocked {
    my $self = shift;
    $self->state && $self->state eq 'unlocked';
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


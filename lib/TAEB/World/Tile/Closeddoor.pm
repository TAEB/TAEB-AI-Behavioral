#!/usr/bin/env perl
package TAEB::World::Tile::Closeddoor;
use TAEB::OO;
extends 'TAEB::World::Tile';
use TAEB::Util ':colors';

has locked => (
    isa     => 'DoorState',
    default => 'unknown',
);

has '+type' => (
    default => 'closeddoor',
);

has is_shop => (
    isa     => 'Bool',
    default => 0,
);

around draw_debug => sub {
    my $orig           = shift;
    my $self           = shift;
    my $display_method = shift;

    if ($self->is_shop) {
        return Curses::addch(Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_RED) | ord $self->$display_method);
    }
    elsif ($self->locked eq 'locked') {
        return Curses::addch(Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_BROWN) | ord $self->$display_method);
    }
    elsif ($self->locked eq 'closed') {
        return Curses::addch(Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_GREEN) | ord $self->$display_method);
    }

    $self->$orig($display_method, @_);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


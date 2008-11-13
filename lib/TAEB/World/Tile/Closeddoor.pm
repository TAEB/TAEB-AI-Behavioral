#!/usr/bin/env perl
package TAEB::World::Tile::Closeddoor;
use TAEB::OO;
extends 'TAEB::World::Tile::Door';
use TAEB::Util ':colors';

has '+type' => (
    default => 'closeddoor',
);

has is_shop => (
    isa     => 'Bool',
    default => 0,
);

augment debug_color => sub {
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
};

__PACKAGE__->meta->make_immutable;
no TAEB::OO;

1;


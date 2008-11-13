#!/usr/bin/env perl
package TAEB::World::Tile::Trap;
use TAEB::OO;
extends 'TAEB::World::Tile';
use TAEB::Util ':colors';

has trap_type => (
    isa => 'Str', # this should become an enum
);

augment debug_color => sub { Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_BLUE) };

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::World::Tile::Trap;
use TAEB::OO;
extends 'TAEB::World::Tile';
use TAEB::Util ':colors';

has trap_type => (
    isa => 'Str', # this should become an enum
);

sub traverse_command { shift->floor_glyph }

around draw_debug => sub {
    my $orig           = shift;
    my $self           = shift;
    my $display_method = shift;

    return Curses::addch(Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_BLUE) | ord $self->$display_method);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


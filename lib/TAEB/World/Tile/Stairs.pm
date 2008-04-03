#!/usr/bin/env perl
package TAEB::World::Tile::Stairs;
use TAEB::OO;
extends 'TAEB::World::Tile';
use TAEB::Util ':colors';

has other_side => (
    isa      => 'TAEB::World::Tile',
    weak_ref => 1,
);

sub traverse_command { shift->floor_glyph }

around draw_debug => sub {
    my $orig           = shift;
    my $self           = shift;
    my $display_method = shift;

    my $different_branch = $self->other_side
                        && $self->other_side->branch
                        && $self->branch
                        && $self->branch ne $self->other_side->branch;

    if ($different_branch) {
        return Curses::addch(Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_BROWN) | ord $self->$display_method);
    }

    $self->$orig($display_method, @_);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


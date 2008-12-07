#!/usr/bin/env perl
package TAEB::World::Tile::Stairs;
use TAEB::OO;
extends 'TAEB::World::Tile';
use TAEB::Util ':colors';

has other_side => (
    isa      => 'TAEB::World::Tile',
    clearer  => 'clear_other_side',
    weak_ref => 1,
);

augment debug_color => sub {
    my $self = shift;

    my $different_branch = $self->known_branch
                        && $self->other_side
                        && $self->other_side->known_branch
                        && $self->branch ne $self->other_side->branch;

    return $different_branch
         ? Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_BROWN)
         : undef;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


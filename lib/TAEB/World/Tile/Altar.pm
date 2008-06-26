#!/usr/bin/env perl
package TAEB::World::Tile::Altar;
use TAEB::OO;
extends 'TAEB::World::Tile';

has alignment => (
    isa       => 'Align',
    predicate => 'has_alignment',
);

sub debug_color {
    my $self = shift;

    return unless $self->has_alignment;

    return Curses::COLOR_PAIR(COLOR_RED)   if $self->alignment eq 'Cha';
    return Curses::COLOR_PAIR(COLOR_GREEN) if $self->alignment eq 'Neu';
    return Curses::COLOR_PAIR(COLOR_CYAN)  if $self->alignment eq 'Law';
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


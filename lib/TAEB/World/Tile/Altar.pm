#!/usr/bin/env perl
package TAEB::World::Tile::Altar;
use TAEB::OO;
extends 'TAEB::World::Tile';

has align => (
    isa       => 'TAEB::Type::Align',
    predicate => 'has_align',
);

sub debug_color {
    my $self = shift;

    return Curses::COLOR_PAIR(Curses::COLOR_RED)   if $self->align eq 'Cha';
    return Curses::COLOR_PAIR(Curses::COLOR_GREEN) if $self->align eq 'Neu';
    return Curses::COLOR_PAIR(Curses::COLOR_CYAN)  if $self->align eq 'Law';

    return Curses::COLOR_PAIR(Curses::COLOR_MAGENTA);
}

sub reblessed {
    my $self = shift;

    TAEB->enqueue_message(check => tile => $self->x, $self->y);
}

sub farlooked {
    my $self = shift;
    my $msg  = shift;

    if ($msg =~ /altar.*(chaotic|neutral|lawful)/) {
        $self->align(ucfirst(substr($1, 0, 3)));
    }
}

around debug_line => sub {
    my $orig = shift;
    my $self = shift;
    my $line = $self->$orig(@_);

    my $align = substr($self->align, 0, 1) || '?';
    return join ' ', $line, 'a<' . $align . '>';
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


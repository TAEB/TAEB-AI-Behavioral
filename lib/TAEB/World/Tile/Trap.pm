#!/usr/bin/env perl
package TAEB::World::Tile::Trap;
use TAEB::OO;
extends 'TAEB::World::Tile';
use TAEB::Util ':colors';

has trap_type => (
    isa => 'TAEB::Type::Trap',
);

augment debug_color => sub { Curses::A_BOLD | Curses::COLOR_PAIR(COLOR_BLUE) };

sub reblessed {
    my $self = shift;

    my $trap_type = $TAEB::Util::trap_colors{$self->color};
    if (ref $trap_type) {
        TAEB->enqueue_message(check => tile => $self);
    }
    else {
        $self->trap_type($trap_type);
    }
}

sub farlooked {
    my $self = shift;
    my $msg  = shift;

    if ($msg =~ /trap.*\((.*?)\)/) {
        $self->trap_type($1);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


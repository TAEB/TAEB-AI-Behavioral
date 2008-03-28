#!/usr/bin/env perl
package TAEB::Action::Ascend;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => '<';
use constant complement_type => 'stairsdown' => '>';

has starting_tile => (
    isa     => 'TAEB::World::Tile',
    default => sub { TAEB->current_tile },
);

sub done {
    my $self    = shift;
    my $start   = $self->starting_tile;
    my $current = TAEB->current_tile;

    if ($start->isa('TAEB::World::Tile::Stairs') && !$start->other_side) {
        TAEB->debug("Setting the other_side of $start to " . $current);
        $start->other_side($current);
    }

    if ($current->type eq 'obscured') {
        $current->change_type($self->complement_type);
        $current->other_side($start);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


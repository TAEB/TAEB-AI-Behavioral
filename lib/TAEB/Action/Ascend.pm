#!/usr/bin/env perl
package TAEB::Action::Ascend;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => '<';

has starting_tile => (
    isa     => 'TAEB::World::Tile',
    default => sub { TAEB->current_tile },
);

sub done {
    my $start = shift->starting_tile;
    if ($start->isa('TAEB::World::Tile::Stairs') && !$start->other_side) {
        TAEB->debug("Setting the other_side of $start to " . TAEB->current_tile);
        $start->other_side(TAEB->current_tile);
        $start->level->add_exit($start);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


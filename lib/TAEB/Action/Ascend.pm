#!/usr/bin/env perl
package TAEB::Action::Ascend;
use TAEB::OO;
extends 'TAEB::Action::Move';

use constant command => '<';
use constant complement_type => 'obscured' => ' ';

has '+direction' => (
    traits   => [qw/TAEB::Provided/],
    provided => 0,
    default  => sub { shift->command },
);

before done => sub {
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
};

after done => sub {
    my $self    = shift;
    my $start   = $self->starting_tile;
    my $current = TAEB->current_tile;

    return unless $self->command eq '<';

    if (my $branch = $start->branch) {
        if ($branch eq 'sokoban' || $branch eq 'vlad') {
            $current->branch($branch);
        }

        # dungeons branch propagates upwards except for sokoban, which is
        # immediately identified
        if ($branch eq 'dungeons' && !$current->known_branch) {
            $current->branch($branch);
        }

        # mines propagates if the new level is 5 or deeper. any higher and we
        # could've left the mines and entered the dungeon
        if ($branch eq 'mines' && $current->z >= 5) {
            $current->branch($branch);
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


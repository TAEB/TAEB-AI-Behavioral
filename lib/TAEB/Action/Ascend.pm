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

        # XXX: this causes TAEB to be permanently in Descender mode, more or
        # less. removing this causes him to go back upstairs to figure out
        # what's on the other side. man I wish I had moomaster's state stacks
        # :)
        #$current->other_side($start);
    }
}

after done => sub {
    my $self    = shift;
    my $start   = $self->starting_tile;
    my $current = TAEB->current_tile;

    if (my $branch = $start->level->branch) {
        if ($branch eq 'sokoban' || $branch eq 'vlad') {
            $current->level->branch($branch);
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Search;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my $path = TAEB::World::Path->max_match(
        sub {
            my ($tile, $path) = @_;

            # search walls and solid rock
            return undef unless $tile->type eq 'wall' || $tile->type eq 'rock';
            return 1 / (($tile->searched + length $path) || 1);
        },
    );

    # are we adjacent to an unsearched wall? if so, begin searching
    if (length($path->path) <= 1) {
        $self->currently("Searching.");
        $self->do('search');
        return 100;
    }

    $self->currently("Heading to a search hotspot");
    $self->do(move => path => $path);
    return 50;
}

sub urgencies {
    return {
        100 => "path to an unsearched wall",
         50 => "searching an adjacent unsearched wall",
    }
}

make_immutable;

1;


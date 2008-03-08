#!/usr/bin/env perl
package TAEB::AI::Behavior::Explore;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;
            !$tile->explored && $tile->is_walkable
        },
    );

    $self->if_path($path, "Exploring", 100);
}

sub urgencies {
    return {
        100 => "path to an unexplored square",
    },
}

make_immutable;

1;


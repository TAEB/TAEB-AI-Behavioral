#!/usr/bin/env perl
package TAEB::AI::Behavior::Search;
use Moose;
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

    $self->path($path);

    return $path && length($path->path) ? 100 : 0;
}

sub next_action {
    my $self = shift;

    # keep moving if we have traveling to do
    return substr($self->path->path, 0, 1) if length($self->path->path) > 1;

    # otherwise begin the search
    TAEB->current_tile->each_neighbor(sub {
        my $self = shift;
        $self->searched($self->searched + 10);
    });

    return '10s';
}

sub currently { "Searching" }

1;


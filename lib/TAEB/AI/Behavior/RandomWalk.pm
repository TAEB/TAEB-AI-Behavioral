#!/usr/bin/env perl
package TAEB::AI::Behavior::RandomWalk;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my @possibilities;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        push @possibilities, $dir if $tile->is_walkable;
    });

    return 0 if !@possibilities;

    $self->next($possibilities[rand @possibilities]);
    return 100;
}

sub currently { "Randomly walking" }

sub urgencies {
    return {
        100 => "random walk!",
    },
}

1;


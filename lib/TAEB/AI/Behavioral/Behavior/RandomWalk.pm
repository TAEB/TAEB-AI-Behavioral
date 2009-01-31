#!/usr/bin/env perl
package TAEB::AI::Behavioral::Behavior::RandomWalk;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my @possibilities;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        push @possibilities, $dir if $tile->is_walkable;
    });

    return if !@possibilities;

    $self->do(move => direction => $possibilities[rand @possibilities]);
    $self->urgency('fallback');
}

sub currently { "Randomly walking" }

sub urgencies {
    return {
        fallback => "random walk!",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Explore;
use Moose;
extends 'TAEB::AI::Behavior';

has path => (
    is  => 'rw',
    isa => 'TAEB::World::Path',
);

sub prepare {
    my $self = shift;

    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;
            !$tile->explored && $tile->is_walkable
        },
    );

    $self->path($path);

    return $path ? 100 : 0;
}

sub next_action {
    my $self = shift;
    substr($self->path->path, 0, 1);
}

sub currently { "Exploring." }

sub max_urgency { 100 }

1;


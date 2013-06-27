#!/usr/bin/env perl
package TAEB::AI::Behavior::WallWalk;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;
    return if (TAEB->current_tile->type ne 'floor');

    # This will currently end up taking steps into an empty doorway
    # Not really that big of an issue
    # Would be fixed with some sort of proper "Am I in the darkness?" check

    my $target;

    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;

        # look for unwalked floor, then for walls next to that floor
        if ($tile->type eq 'floor' && !$tile->stepped_on) {
            my $wall;
            my $dark;
            TAEB->each_adjacent(sub {
                my ($tile, $dir) = @_;
                $dark++ if $tile->type eq 'rock'
                        || $tile->type eq 'unexplored';
                $wall++ if $tile->type eq 'wall';
                }, $tile);
            if ($dark && $wall) {
                $target = 1;
                $self->do(move => direction => $dir);
                $self->currently("Wallwalking in a dark room");
            }
        }
    });
    return $self->urgency('fallback') if $target;
}

sub urgencies {
    return {
        fallback => "wallwalking in a dark room",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::WallWalk;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;
    my $target;
    my $wall;
    my $dark;
    return 0 if (TAEB->current_tile->type ne 'floor');

    #This will currently end up taking steps into an empty doorway
    #Not really that big of an issue
    #
    #Would be fixed with some sort of proper "Am I in the darkness?" check

    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        #look for unwalked floor, then for walls next to that floor
        if ($tile->type eq 'floor' && !$tile->stepped_on) {
            $wall = 0;
            $dark = 0;
            TAEB->each_adjacent(sub {
                my ($tile, $dir) = @_;
                $dark = 1 if $tile->type eq 'rock';
                $wall = 1 if $tile->type eq 'wall';
                }, $tile);
            if ($dark && $wall) {
                $target = 1;
                $self->next($dir);
                $self->currently("Wall Walking a dark room");
            }
        }
    });
   return $target ? 100 : 0;
}

sub urgencies {
    return {
        100 => "wallwalking in a dark room",
    },
}
1;


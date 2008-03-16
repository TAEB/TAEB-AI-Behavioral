#!/usr/bin/env perl
package TAEB::AI::Behavior::Explore;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

has done_exploring => (
    isa     => 'Bool',
    default => 0,
);

sub prepare {
    my $self = shift;

    return 0 if $self->done_exploring;

    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;
            !$tile->explored && $tile->is_walkable
        },
    );

    $self->done_exploring(1) if !$path;

    $self->if_path($path, "Exploring", 100);
}

sub urgencies {
    return {
        100 => "path to an unexplored square",
    },
}

sub msg_tile_update {
    my $self = shift;
    $self->done_exploring(0);
}

sub msg_dlvl_change {
    my $self = shift;
    $self->done_exploring(0);
}

make_immutable;
no Moose;

1;


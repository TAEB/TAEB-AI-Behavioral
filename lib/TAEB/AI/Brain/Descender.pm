#!/usr/bin/env perl
package TAEB::AI::Brain::Descender;
use Moose;
extends 'TAEB::AI::Brain';

=head1 NAME

TAEB::AI::Brain::Descender - descend as quickly as sanely possible

=cut

sub weight_behaviors {
    return {
        FixHunger          => 1_000_000,

        Descend            => 80_000,
        # Descend:            80_000
        Fight              => 50_000,
        # Elbereth:           50_000
        # Attack:             45_000
        # Path to downstairs: 40_000
        # Path to monster:    25_000
        Doors              => 10_000,
        # Kick:               10_000
        # Path to door:       5_000

        Explore            => 2_500,
        Search             => 1_000,
        RandomWalk         => 1,
    };
}

sub autoload_behaviors { keys %{ weight_behaviors() } }

sub next_action {
    shift->behavior_action;
}

1;


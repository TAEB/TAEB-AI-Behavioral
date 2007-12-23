#!/usr/bin/env perl
package TAEB::AI::Brain::Descender;
use Moose;
extends 'TAEB::AI::Brain';

=head1 NAME

TAEB::AI::Brain::Descender - descend as quickly as sanely possible

=cut

sub autoload_behaviors { qw/Explore FixHunger Descend Search Doors/ }

sub weight_behaviors {
    return {
        FixHunger => 10000,
        Descend   => 5000,
        Doors     => 4000,
        Explore   => 2500,
        Search    => 1000,
    };
}

sub next_action {
    shift->behavior_action;
}

1;


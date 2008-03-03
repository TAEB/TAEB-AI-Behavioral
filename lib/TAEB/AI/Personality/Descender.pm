#!/usr/bin/env perl
package TAEB::AI::Personality::Descender;
use Moose;
extends 'TAEB::AI::Personality::Behavioral';

=head1 NAME

TAEB::AI::Personality::Descender - descend as quickly as sanely possible

=cut

sub weight_behaviors {
    return {
        FixHunger          => 1_000_000,
        Heal               => 750_000,
        Descend            => 80_000,
        Fight              => 50_000,
        Projectiles        => 49_000,
        DipForExcalibur    => 24_500,
        GetItems           => 24_000,
        Doors              => 10_000,
        Explore            => 2_500,
        Search             => 1_000,
        RandomWalk         => 1,
    };
}

make_immutable;

1;


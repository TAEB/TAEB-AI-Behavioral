#!/usr/bin/env perl
package TAEB::AI::Personality::Explorer;
use Moose;
extends 'TAEB::AI::Personality::Behavioral';

=head1 NAME

TAEB::AI::Personality::Explore - descend only after exploring the level

=cut

sub weight_behaviors {
    return {
        FixHunger          => 1_000_000,
        Heal               => 750_000,
        AttackSpell        => 75_000,
        BuffSelf           => 70_000,
        Fight              => 50_000,
        Projectiles        => 49_000,
        DipForExcalibur    => 24_500,
        GetItems           => 24_000,
        Doors              => 10_000,
        DeadEnd            => 5_000,
        Explore            => 2_500,
        Descend            => 1_000,
        Search             => 300,
        RandomWalk         => 1,
    };
}

make_immutable;

1;


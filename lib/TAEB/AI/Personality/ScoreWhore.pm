#!/usr/bin/env perl
package TAEB::AI::Personality::ScoreWhore;
use TAEB::OO;
extends 'TAEB::AI::Personality::Behavioral';

has time_spent_on => (
    isa           => 'HashRef[Int]',
    default       => sub { {} },
    documentation => "How much time was spent (in other words, how many actions were made) on each level",
);

=head1 NAME

TAEB::AI::Personality::ScoreWhore - milk each dungeon level for as long as possible

=head1 DESCRIPTION

This personality will avoid descending until its experience level is greater
than its dungeon level, or it spent 1000 turns on the current level.

This is an example of shifting the weight of a behavior around.

=cut

sub weight_behaviors {
    my $self = shift;

    my $behaviors = {
        FixHunger          => 1_000_000,
        Heal               => 750_000,
        FixStatus          => 700_000,
        Defend             => 400_000,
        AttackSpell        => 75_000,
        BuffSelf           => 70_000,
        Fight              => 50_000,
        Projectiles        => 49_000,
        AttackSpell        => 48_500,
        DipForExcalibur    => 24_500,
        GetItems           => 24_000,
        Doors              => 10_000,
        DeadEnd            => 5_000,
        Explore            => 2_500,
        Search             => 1_000,
        Descend            => 2,
        RandomWalk         => 1,
    };

    # Descend at a very leisurely pace
    $behaviors->{Descend} = 2000 if TAEB->level > TAEB->z
                                 || $self->time_spent_on->{TAEB->z}++ >= 1000;

    return $behaviors;
}

make_immutable;
no Moose;

1;


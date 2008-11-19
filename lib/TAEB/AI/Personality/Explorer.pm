#!/usr/bin/env perl
package TAEB::AI::Personality::Explorer;
use TAEB::OO;
extends 'TAEB::AI::Personality::Behavioral';

=head1 NAME

TAEB::AI::Personality::Explore - descend only after exploring the level

=cut

sub sort_behaviors {
    my $self = shift;
    my $fight = TAEB->config->fight_behavior || 'Melee';

    $self->prioritized_behaviors([
        "FixHunger",
        "Heal",
        "FixStatus",
        "Defend",
        "AttackSpell",
        "BuffSelf",
        "Chokepoint",
        "Kite",
        "$fight",
        "Projectiles",
        "Vault",
        "Shop",
        "Carrion",
        "GetItems",
        "Identify",
        "DipForExcalibur",
        "Wish",
        "BuyProtection",
        "Doors",
        "DeadEnd",
        "Explore",
        "CurseCheck",
        "Descend",
        "Search",
        "RandomWalk",
    ]);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


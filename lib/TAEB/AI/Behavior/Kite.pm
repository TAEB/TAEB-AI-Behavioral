#!/usr/bin/env perl

# Kiting - speed system (ab)use by attacking while running away to prevent
#   counterattacks.  Currently we only handle projectile attacks against
#   single melee monsters, which suffices for the very important case of
#   nymphs and foocubi.

package TAEB::AI::Behavior::Kite;
use TAEB::OO;
use TAEB::Util 'delta2vi';
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my @enemies = grep { $_->in_los } TAEB->current_level->has_enemies;

    # For now, only handle one-on-one fights
    return 0 unless @enemies == 1;

    my $enemy = $enemies[0];

    # and unless the enemy is next to us and kitable, act normally
    return 0 unless abs($enemy->x - TAEB->x) <= 1
                 && abs($enemy->y - TAEB->y) <= 1;

    return 0 unless $enemy->can_outrun;
    #return 0 unless $enemy->melee_disposition == -1;

    # do we have a projectile to throw?  No sense backing away otherwise (yet)
    return 0 unless defined (TAEB->inventory->has_projectiles);

    my $back = delta2vi (TAEB->x - $enemy->x, TAEB->y - $enemy->y);
    # CAN we back up?
    return 0 unless TAEB->current_level->at_direction($back)->is_walkable;

    $self->do(move =>
        direction   => $back,
    );
    $self->currently("Kiting.");
    return 100;
}

sub urgencies {
    return {
        100 => "backing away from an outrunnable melee monster with intent to kite",
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


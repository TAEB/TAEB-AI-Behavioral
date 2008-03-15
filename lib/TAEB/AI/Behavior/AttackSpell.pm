#!/usr/bin/env perl
package TAEB::AI::Behavior::AttackSpell;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub use_spells { ('magic missile', 'sleep') }

sub prepare {
    my $self = shift;

    my $spell;
    for ($self->use_spells) {
        $spell = TAEB->find_castable($_) and last;
    }

    return 0 unless $spell;

    my $direction = TAEB->current_level->radiate(
        sub { shift->has_monster },

        # how far to radiate. we can eventually calculate how far $projectile
        # can travel..!
        max => 6,
    );

    # no monster found
    return 0 if !$direction;

    $self->do(cast => spell => $spell, direction => $direction);
    $self->currently("Casting ".$spell->name." at a monster");
    return 100;
}

sub urgencies {
    return {
        100 => "casting an attack spell at a monster",
    };
}

make_immutable;

1;


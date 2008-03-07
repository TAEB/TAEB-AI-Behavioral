#!/usr/bin/env perl
package TAEB::AI::Behavior::AttackSpell;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # do we have an attack spell?
    my $spell = TAEB->find_castable("sleep")
        or return 0;

    my $direction = TAEB->current_level->radiate(
        sub { shift->has_monster },

        # how far to radiate. we can eventually calculate how far $projectile
        # can travel..!
        max => 6,
    );

    # no monster found
    return 0 if !$direction;

    $self->next('Z' . $spell->slot . $direction);
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


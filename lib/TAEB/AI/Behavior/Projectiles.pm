#!/usr/bin/env perl
package TAEB::AI::Behavior::Projectiles;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # do we have a projectile to throw?
    my $projectile = TAEB->inventory->find($self->can('pickup'))
        or return 0;

    my $direction = TAEB->current_level->radiate(
        sub { shift->has_monster },

        # how far to radiate. we can eventually calculate how far $projectile
        # can travel..!
        max => 6,
    );

    # no monster found
    return 0 if !$direction;

    $self->next(join '', 't', $projectile->slot, $direction);
    $self->currently("Throwing a " . $projectile->appearance . " at a monster.");
    return 100;
}

sub pickup {
    /dagger/ || /dart/
}

sub urgencies {
    return {
        100 => "throwing a projectile weapon at a monster",
    };
}

1;


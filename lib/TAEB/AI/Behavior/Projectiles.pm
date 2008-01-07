#!/usr/bin/env perl
package TAEB::AI::Behavior::Projectiles;
use Moose;
extends 'TAEB::AI::Behavior';

use TAEB::Util 'direction', 'deltas';

sub prepare {
    my $self = shift;
    my $direction;

    # do we have a projectile to throw?
    my $projectile = TAEB->inventory->find_item($self->can('pickup'))
        or return;

    # XXX: this needs to be refactored into the framework
    # check each direction...
    DIRECTION: for (deltas) {
        my ($dx, $dy) = @$_;
        my ($x, $y) = (TAEB->x, TAEB->y);

        # check up to six tiles out
        # XXX: TAEB could calculate how far he could throw $projectile..
        for (1 .. 6) {
            $x += $dx; $y += $dy;
            my $tile = TAEB->current_level->at($x, $y) or next DIRECTION;

            if ($tile->has_monster) {
                $direction = direction($x, $y);
                last DIRECTION;
            }

            # this check could be better. we don't want to throw a dagger if:
            #   |...@.|#j

            $tile->is_walkable or next DIRECTION;

        }
    }

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


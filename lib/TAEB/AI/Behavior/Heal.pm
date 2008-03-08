#!/usr/bin/env perl
package TAEB::AI::Behavior::Heal;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return 0 if TAEB->hp * 2 > TAEB->maxhp;

    my $spell = TAEB->find_castable("healing")
             || TAEB->find_castable("extra healing");
    if ($spell) {
        $self->do(cast => spell => $spell, direction => ".");
        $self->currently("Casting heal at myself.");
        return 100;
    }

    # we've probably been writing Elbereth a bunch, so find a healing potion
    if (TAEB->hp * 3 < TAEB->maxhp) {
        my $potion = TAEB->find_item("potion of healing")
                  || TAEB->find_item("potion of extra healing")
                  || TAEB->find_item("potion of full healing");
        if ($potion) {
            $self->do(quaff => from => $potion);
            $self->currently("Quaffing a $potion");
            return 90;
        }
    }

    if (TAEB->can_elbereth) {
        $self->write_elbereth;
        return 80;
    }

    return 0;
}

sub urgencies {
    return {
       100 => "casting a healing spell",
        90 => "quaffing a potion of healing, extra healing, or full healing",
        80 => "writing Elbereth due to low HP",
    },
}

make_immutable;

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Heal;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return 0 if TAEB->hp * 2 > TAEB->maxhp;

    if (my $spell = TAEB->find_castable("healing")) {
        $self->next("Z" . $spell->slot . ".");
        $self->currently("Casting heal at myself.");
        return 100;
    }

    unless (TAEB->senses->in_wereform || TAEB->senses->is_blind) {
        $self->write_elbereth;
        return 80;
    }

    return 0;
}

sub urgencies {
    return {
       100 => "casting a healing spell",
        80 => "writing Elbereth due to low HP",
    },
}

make_immutable;

1;


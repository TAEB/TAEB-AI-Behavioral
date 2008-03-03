#!/usr/bin/env perl
package TAEB::AI::Behavior::Heal;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # if we can't write Elbereth, then forget it
    return 0 if TAEB->senses->in_wereform;
    return 0 if TAEB->senses->is_blind;

    if (TAEB->hp * 2 < TAEB->maxhp) {
        $self->write_elbereth;
        return 100;
    }
}

sub urgencies {
    return {
        100 => "writing Elbereth due to low HP",
    },
}

make_immutable;

1;


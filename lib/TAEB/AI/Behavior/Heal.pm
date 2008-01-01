#!/usr/bin/env perl
package TAEB::AI::Behavior::Heal;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # if we're at 50% health or less and we can write Elbereth, do it
    if (TAEB->hp * 2 < TAEB->maxhp && !TAEB->senses->in_wereform) {
        $self->write_elbereth;
        return 100;
    }
}

sub weights {
    return {
        100 => "writing Elbereth due to low HP",
    },
}

1;


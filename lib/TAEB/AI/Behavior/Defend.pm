#!/usr/bin/env perl
package TAEB::AI::Behavior::Defend;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;
    return 0 if TAEB->hp * 2 > TAEB->maxhp;

    if (TAEB->can_elbereth) {
        $self->write_elbereth;
        return 100;
    }

    return 0;
}

sub urgencies {
    return {
       100 => "writing Elbereth due to low HP",
    },
}

make_immutable;
no Moose;

1;


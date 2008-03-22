#!/usr/bin/env perl
package TAEB::AI::Behavior::Defend;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;
    return 0 if TAEB->hp * 2 > TAEB->maxhp;

    if (TAEB->can_elbereth && TAEB->senses->elbereth_count < 3) {
        $self->write_elbereth;
        return 100;
    }

    $self->currently("Resting on an Elbereth tile.");
    $self->do('search');
    return 80;
}

sub urgencies {
    return {
       100 => "writing Elbereth due to low HP",
       80  => "resting on an Elbereth tile",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


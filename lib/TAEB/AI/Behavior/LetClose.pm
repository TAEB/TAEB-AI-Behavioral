#!/usr/bin/env perl

package TAEB::AI::Behavior::LetClose;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my @enemies = grep { $_->in_los } TAEB->current_level->has_enemies;

    my @beckon = grep { $_->will_chase && distance($_) > 1 } @enemies;

    if (@beckon) {
        $self->write_elbereth;  # this gem taken from EkimFight.  Why not?
        $self->urgency('normal');
    }
}

sub urgencies {
    return {
        normal => "Letting an enemy close",
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


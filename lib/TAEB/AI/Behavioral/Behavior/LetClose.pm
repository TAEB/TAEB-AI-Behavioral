#!/usr/bin/env perl
package TAEB::AI::Behavioral::Behavior::LetClose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my @enemies = grep { $_->in_los } TAEB->current_level->has_enemies;

    my @beckon = grep { $_->will_chase && $_->distance >= 2
        && $_->is_meleeable && $_->distance < 4} @enemies;

    if (@beckon) {
        #$self->write_elbereth;  # this gem taken from EkimFight.  Why not?
        # well, it makes monsters FLEE, and we patiently wait for them to
        # get away due to statelessness...

        $self->do('search', iterations => 1);
        $self->currently('Waiting');
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


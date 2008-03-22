#!/usr/bin/env perl
package TAEB::AI::Behavior::AttackSpell;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub use_spells { ('magic missile', 'sleep') }

sub use_wands {
    map { "wand of $_" }
    'striking', 'sleep', 'death', 'magic missile', 'cold', 'fire', 'lightning'
}

sub prepare {
    my $self = shift;

    my ($spell, $wand);

    for ($self->use_spells) {
        $spell = TAEB->find_castable($_) and last;
    }

    unless ($spell) {
        for ($self->use_wands) {
            $wand = TAEB->find_item($_) and last;
        }
    }

    return 0 unless $spell || $wand;

    my $direction = TAEB->current_level->radiate(
        sub { shift->has_monster },

        # how far to radiate. we can eventually calculate how far beam/ray
        # can travel..!
        max => 6,
    );

    # no monster found
    return 0 if !$direction;

    if ($spell) {
        $self->do(cast => spell => $spell, direction => $direction);
        $self->currently("Casting ".$spell->name." at a monster");
        return 100;
    }

    if ($wand) {
        $self->do(zap => item => $wand, direction => $direction);
        $self->currently("Zapping a ".$wand->identity." at a monster");
        return 90;
    }

    return 0;
}

sub urgencies {
    return {
        100 => "casting an attack spell at a monster",
         90 => "zapping a wand at a monster",
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


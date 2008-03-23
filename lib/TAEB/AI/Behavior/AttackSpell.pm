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
        for my $desired ($self->use_wands) {
            $wand = TAEB->find_item(sub {
                my $item = shift;
                return 0 unless $item->identity eq $desired;
                return 1 if !defined($item->charges);
                return 1 if $item->charges;
                return 0;
            }) and last;
        }
    }

    return 0 unless $spell || $wand;

    my $direction = TAEB->current_level->radiate(
        sub { shift->monster },

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
        return 50;
    }

    return 0;
}

sub urgencies {
    return {
        100 => "casting an attack spell at a monster",
         50 => "zapping a wand at a monster",
    };
}

sub pickup {
    my $self = shift;
    my $item = shift;

    for ($self->use_wands) {
        return 1 if $item->identity eq $_;
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


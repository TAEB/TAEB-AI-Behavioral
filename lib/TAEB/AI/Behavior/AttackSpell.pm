#!/usr/bin/env perl
package TAEB::AI::Behavior::AttackSpell;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub use_spells { ('magic missile', 'sleep', 'force bolt') }

sub use_wands {
    map { "wand of $_" }
    'striking', 'sleep', 'death', 'magic missile', 'cold', 'fire', 'lightning'
}

sub prepare {
    my $self = shift;

    return URG_NONE unless TAEB->current_level->has_enemies;

    my ($spell, $wand);
    my $urgency = URG_NONE;
    for ($self->use_spells) {
        $spell = TAEB->find_castable($_);
        next unless $spell;
        $urgency = $self->try_to_cast(spell => $spell);
        TAEB->debug("Considering spell $spell, urgency $urgency");
        return $urgency if $urgency > URG_NONE;
    }

    unless ($spell) {
        for my $desired ($self->use_wands) {
            $wand = TAEB->find_item(sub {
                shift->match(identity => $desired,
                             charges  => sub { shift > 0 });
            });
            next unless $wand;
            $urgency = $self->try_to_cast(wand => $wand);
            return $urgency if $urgency > URG_NONE;
        }
    }
    return URG_NONE;
}

sub try_to_cast {
    my $self = shift;
    my %args = @_;
    my $spell = $args{spell};
    my $wand = $args{wand};

    my $direction = TAEB->current_level->radiate(
        sub { 
            my $tile = shift;
            return 0 unless $tile->has_enemy;
            if ((defined($spell) && $spell eq 'sleep') || (defined($wand) && $wand eq 'wand of sleep')) {
                return 0 unless $tile->monster->is_sleepable;
            }
            return 1;
        },
        stopper => sub { shift->has_friendly },

        # how far to radiate. we can eventually calculate how far beam/ray
        # can travel..!
        max => 6,
    );

    # no monster found
    return URG_NONE if !$direction;

    if ($spell) {
        $self->do(cast => spell => $spell, direction => $direction);
        $self->currently("Casting ".$spell->name." at a monster");
        return URG_NORMAL;
    }

    if ($wand) {
        $self->do(zap => item => $wand, direction => $direction);
        $self->currently("Zapping a ".$wand->identity." at a monster");
        return URG_NORMAL;
    }

    return 0;
}

sub urgencies {
    return {
        URG_NORMAL, "casting an attack spell or zapping an attack wand at a monster",
    };
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return $item->match(identity => [$self->use_wands]);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


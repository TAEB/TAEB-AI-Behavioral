#!/usr/bin/env perl
package TAEB::AI::Behavioral::Behavior::AttackSpell;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub use_spells { ('magic missile', 'sleep', 'force bolt') }

sub use_wands {
    map { "wand of $_" }
    'striking', 'sleep', 'death', 'magic missile', 'cold', 'fire', 'lightning'
}

sub prepare {
    my $self = shift;

    return unless TAEB->current_level->has_enemies;

    my ($spell, $wand);
    for ($self->use_spells) {
        $spell = TAEB->find_castable($_);
        next unless $spell;
        TAEB->log->behavior("Considering spell $spell");
        if ($self->try_to_cast(spell => $spell)) {
            $self->urgency('normal');
            return;
        }
    }

    unless ($spell) {
        for my $desired ($self->use_wands) {
            $wand = TAEB->find_item(identity => $desired,
                                    charges  => [undef, sub { $_ > 0 }]);
            next unless $wand;
            TAEB->log->behavior("Considering wand $wand");
            if ($self->try_to_cast(wand => $wand)) {
                $self->urgency('normal');
                return;
            }
        }
    }
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
    return 0 if !$direction;

    if ($spell) {
        $self->do(cast => spell => $spell, direction => $direction);
        $self->currently("Casting ".$spell->name." at a monster");
        return 1;
    }

    if ($wand) {
        $self->do(zap => item => $wand, direction => $direction);
        $self->currently("Zapping a ".$wand->identity." at a monster");
        return 1;
    }

    return 0;
}

sub urgencies {
    return {
        normal => "casting an attack spell or zapping an attack wand at a monster",
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


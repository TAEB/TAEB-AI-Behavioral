#!/usr/bin/env perl
package TAEB::AI::Behavior::Carrion;
use TAEB::OO;
extends 'TAEB::AI::Behavior::GotoTile';

sub want_to_eat {
    my ($self, $item) = @_;

    return 0 unless $item->class eq 'carrion';
    my $rotted = $item->maybe_rotted;
    my $unihorn = TAEB->find_item(identity => "unicorn horn",
        buc => [qw/blessed uncursed/]);

    # Don't bother eating food that is clearly rotten, and don't risk it
    # without a known-uncursed unihorn
    return 0 if ($rotted > ($unihorn ? -1 : 0));

    # No food suicides
    for my $foot (qw/die lycanthropy petrify polymorph slime/) {
        return 0 if $item->$foot();
    }

    if (!$unihorn) {
        # Don't inflict very bad conditions

        return 0 if $item->hallucination;
        return 0 if $item->poisonous && !TAEB->senses->poison_resistant;
    }

    return 0 if $item->acidic && TAEB->hp <= 15;
    return 0 if $item->poisonous && !TAEB->senses->poison_resistant &&
        TAEB->hp <= 29;  # worst case is Str-dependant and usuallly milder
    return 0 if ($item->cannibal eq TAEB->race || $item->aggravate) &&
        !(TAEB->race eq 'Orc' || TAEB->role eq 'Cav');
    return 0 if $item->speed_toggle && TAEB->is_fast;
    return 0 if $item->teleportitis && !$item->teleport_control;

    my $intrinsic = 0;

    for my $nice (qw/disintegration_resistance energy gain_level heal
            intelligence invisibility sleep_resistance speed_toggle
            strength telepathy teleport_control teleportitis/) {
        $intrinsic = 1 if $item->$nice();
    }

    for my $resist (qw/shock poison fire cold/) {
        my $prop = "${resist}_resistance";
        my $res  = "${resist}_resistant";
        $intrinsic = 1 if $item->$prop() && !TAEB->$res();
    }

    # XXX when we can track nutrition gain
    return 1 if TAEB->nutrition < 900;
    #return 1 if $intrinsic && ($item->nutrition + TAEB->nutrition < 2000);

    return 0;
}

sub first_pass {
    my $self = shift;

    grep { $self->want_to_eat($_) } TAEB->current_level->items;
}

sub match_tile {
    my ($self, $tile) = @_;

    my @yummy = grep { $self->want_to_eat($_) } $tile->items;

    if (@yummy) {
        return [eat => item => $yummy[0]->identity],
            "eating a " . $yummy[0]->identity;
    } else {
        return undef;
    }
}

sub tile_description { "a corpse" }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::World::Item::Carrion;
use TAEB::OO;
use TAEB::Spoilers::Monster;
extends 'TAEB::World::Item::Food';

has '+class' => (
    default => 'carrion',
);

has is_forced_verboten => (
    isa     => 'Bool',
    default => 0,
);

has estimated_date => (
    isa     => 'Int',
    default => 0,
);

sub estimate_age { TAEB->turn - shift->estimated_date; }

sub maybe_rotted {
    my $self = shift;

    my $rl = int($self->estimate_age / 29);
    my $rh = int($self->estimate_age / 10);

    if ($self->buc eq 'blessed') {
        $rl -= 2; $rh -= 2;
    } elsif ($self->buc eq 'uncursed') {
    } elsif ($self->buc eq 'cursed') {
        $rl += 2; $rh += 2;
    } else {
        $rl -= 2; $rh += 2;
    }

    $rh = 10 if $self->is_forced_verboten;

    return 0 if $self->monster =~ /^(?:lizard|lichen|acid blob)$/;
    return ($rh > 5) - ($rl > 5);
}

sub monster {
    (shift->identity) =~ /(.*)(?:'s?)? corpse/;

    return $1;
}

__PACKAGE__->install_spoilers(qw/acidic aggravate cannibal cold_resistance
    cure_confusion cure_stoning die disintegration_resistance energy
    fire_resistance gain_level hallucination heal intelligence invisibility
    lycanthropy mimic nutrition petrify poison_resistance poisonous polymorph
    reduce_stunning shock_resistance sleep_resistance slime speed_toggle
    strength stun telepathy teleport_control teleportitis vegan vegetarian
    weight/);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


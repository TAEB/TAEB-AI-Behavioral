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

    my $rotted_low = int($self->estimate_age / 29);
    my $rotted_high = int($self->estimate_age / 10);

    if (!defined($self->buc)) {
        $rotted_low -= 2; $rotted_high += 2;
    } elsif ($self->buc eq 'blessed') {
        $rotted_low -= 2; $rotted_high -= 2;
    } elsif ($self->buc eq 'uncursed') {
    } elsif ($self->buc eq 'cursed') {
        $rotted_low += 2; $rotted_high += 2;
    }

    $rotted_high = 10 if $self->is_forced_verboten;

    return 0 if $self->monster =~ /^(?:lizard|lichen|acid blob)$/;
    TAEB->debug ("in maybe_rotted; " . $rotted_low . "-" . $rotted_high .
        " for " . $self->raw . "(" . $self->estimate_age . ")" .
        $self->is_forced_verboten);
    return (($rotted_high > 5) - ($rotted_low > 5));
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


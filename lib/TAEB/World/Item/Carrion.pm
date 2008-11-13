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


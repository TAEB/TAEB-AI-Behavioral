#!/usr/bin/env perl
package TAEB::Action::Cast;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

use constant command => 'Z';

has spell => (
    isa      => 'TAEB::Knowledge::Spell',
    required => 1,
);

sub respond_which_spell { shift->spell->slot }

sub done {
    my $spell = shift->spell;

    # detect food doesn't make us hungry
    return if $spell->name eq 'detect food';

    my $nutrition = TAEB->senses->nutrition;

    # in the future, let's check to see how much we actually spent (Amulet of
    # Yendor)
    my $energy = 5 * $spell->power;
    my $hunger = 2 * $energy;

    if (TAEB->role eq 'Wiz') {
           if (TAEB->int >= 17) { $hunger = 0 }
        elsif (TAEB->int == 16) { $hunger = int($hunger / 4) }
        elsif (TAEB->int == 15) { $hunger = int($hunger / 2) }
    }

    if ($hunger > $nutrition - 3) {
        $hunger = $nutrition - 3;
    }

    TAEB->senses->nutrition($nutrition - $hunger);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


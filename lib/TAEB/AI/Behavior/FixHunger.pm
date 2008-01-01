#!/usr/bin/env perl
package TAEB::AI::Behavior::FixHunger;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return TAEB->vt->row_plaintext(23) =~ /\bFai/ ? 100 : 0;
}

sub next_action { "#pray\n" }

sub currently { "Praying for food" }

sub weights {
    return {
        100 => "praying for food, while fainting",
    },
}

sub pickup {
    my $food = TAEB::Knowledge::Item::Food->food($_) or return 0;
    $food->{weight} < 100 or return 0;
    return TAEB::Knowledge::Item::Food->should_eat($food);
}

1;


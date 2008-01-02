#!/usr/bin/env perl
package TAEB::AI::Behavior::FixHunger;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    if (TAEB->senses->hunger < 0) {
        $self->next("#pray\n");
        $self->currently("Praying for food.");
        return 100;
    }

    if (TAEB->senses->hunger < 400) {
        $self->next("e...");
        $self->currently("Eating food.");
        return 0;
    }

    return 0;
}

sub weights {
    return {
        100 => "praying for food, while fainting",
         50 => "eating food because hunger is < 400",
    },
}

sub pickup {
    my $food = TAEB::Knowledge::Item::Food->food($_) or return 0;
    $food->{weight} < 100 or return 0;
    return TAEB::Knowledge::Item::Food->should_eat($food);
}

1;


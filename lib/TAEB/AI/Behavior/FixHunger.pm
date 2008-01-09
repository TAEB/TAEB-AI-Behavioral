#!/usr/bin/env perl
package TAEB::AI::Behavior::FixHunger;
use Moose;
extends 'TAEB::AI::Behavior';

has inv_dirty => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has goodeats => (
    is   => 'rw',
    isa  => 'TAEB::World::Item',
);

sub prepare {
    my $self = shift;

    if (TAEB->senses->nutrition < 0) {
        $self->next("#pray\n");
        $self->currently("Praying for food.");
        return 100;
    }

    if (TAEB->senses->nutrition < 400) {
        for my $item (TAEB->inventory->items) {
            if (TAEB::Knowledge::Item::Food->should_eat($item->appearance)) {
                $self->next("e" . $item->slot);
                $self->currently("Eating food.");
                return 50;
            }
        }
    }

    return 0;
}

sub urgencies {
    return {
        100 => "praying for food, while fainting",
         50 => "eating food because nutrition is < 400",
    },
}

sub pickup {
    my $food = TAEB::Knowledge::Item::Food->food($_) or return 0;
    $food->{weight} < 100 or return 0;
    return TAEB::Knowledge::Item::Food->should_eat($food);
}

1;


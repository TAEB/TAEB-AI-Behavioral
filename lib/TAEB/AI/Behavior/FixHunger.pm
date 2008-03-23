#!/usr/bin/env perl
package TAEB::AI::Behavior::FixHunger;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    if (TAEB->can_pray && TAEB->senses->nutrition < 0) {
        $self->do("pray");
        $self->currently("Praying for food.");
        return 100;
    }

    if (TAEB->senses->nutrition < 400 && TAEB::Action::Eat->any_food) {
        $self->do(eat => item => 'any');
        $self->currently("Eating food.");
        return 50;
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
    my $self = shift;
    my $item = shift;
    $item->weight < 100 or return 0;
    return TAEB::Spoilers::Item::Food->should_eat($item);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


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

    $self->goodeats(undef);
    if (TAEB->senses->nutrition < 0) {
        $self->next("#pray\n");
        $self->currently("Praying for food.");
        return 100;
    }
    if ($self->inv_dirty) {
        $self->next("Da\n");
        $self->currently("Refreshing inventory after eating");
        $self->inv_dirty(0);
        return 90;
    }
    if (TAEB->senses->nutrition < 400 && !$self->inv_dirty) {
        for my $item (TAEB->inventory->items) {
            if (TAEB::Knowledge::Item::Food->should_eat($item->appearance)) {
                $self->next("e" . $item->slot);
                $self->currently("Eating " . $item->appearance . " from " . $item->slot);
                $self->inv_dirty(1);
                $self->goodeats($item);
                return 50;
            }
        }
    }

    return 0;
}
after next_action => sub {
    my $self = shift;
    if ($self->goodeats) {
        TAEB->inventory->decrease_quantity($self->goodeats->slot);
    }
};
sub urgencies {
    return {
        100 => "praying for food, while fainting",
         90 => "refreshing inventory because I ate",
         50 => "eating food because nutrition is < 400",
    },
}

sub pickup {
    my $food = TAEB::Knowledge::Item::Food->food($_) or return 0;
    $food->{weight} < 100 or return 0;
    return TAEB::Knowledge::Item::Food->should_eat($food);
}

1;


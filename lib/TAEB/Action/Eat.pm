#!/usr/bin/env perl
package TAEB::Action::Eat;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "e";

has food => (
    isa      => 'TAEB::World::Item | Str',
    required => 1,
);

sub respond_eat_ground {
    my $self = shift;
    my $msg  = shift;
    my $food = shift;

    # no, we want to eat something in our inventory
    return 'n' if blessed $self->food;

    if ($self->food eq 'any' && TAEB::Spoilers::Item::Food->should_eat($food)) {
        # keep track of what we're eating for nutrition purposes later
        $self->food($food);
        return 'y';
    }

    # we're specific about this. really
    return 'y' if $food eq $self->food;

    # no thanks, I brought my own lunch
    return 'n';
}

sub respond_eat_what {
    my $self = shift;
    return $self->food->slot if blessed($self->food);

    if ($self->food eq 'any') {
        my $food = TAEB->find_item(sub {
            my $try = shift;
            return $try->class eq 'food'
                && TAEB::Spoilers::Item::Food->should_eat($try);
        });
        if ($food) {
            $self->food($food);
            return $food->slot;
        }
        TAEB->error("There's no safe food in my inventory, so I can't eat 'anything'. Sending escape, but I doubt this will work.");
    }
    else {
        TAEB->error("Unable to eat '" . $self->food . "'. Sending escape, but I doubt this will work.");
    }
    return "\e";
}

sub done {
    my $self = shift;
    my $food = $self->food;

    if (blessed $food) {
        TAEB->inventory->decrease_quantity($food->slot)
    }
    else {
        $food = TAEB::World::Item->new_item($food);
    }

    TAEB->debug("Eating $food is increasing our nutrition by " . $food->nutrition);
    TAEB->senses->nutrition(TAEB->senses->nutrition + $food->nutrition);
}

# is there any food around?
sub any_food {
    my $self = shift;

    for (TAEB->current_tile->items, TAEB->inventory->items) {
        return 1 if $_->class eq 'food'
                 && TAEB::Spoilers::Item::Food->should_eat($_);
    }

    return 0;
}

make_immutable;
no Moose;

1;


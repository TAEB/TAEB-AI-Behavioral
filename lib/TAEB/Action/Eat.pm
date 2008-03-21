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
    my $food = TAEB->new_item(shift);

    # no, we want to eat something in our inventory
    return 'n' if blessed $self->food;

    if ($self->food eq 'any') {
        if (TAEB::Spoilers::Item::Food->should_eat($food)) {
            TAEB->debug("Floor-food $food is good enough for me.");
            # keep track of what we're eating for nutrition purposes later
            $self->food($food);
            return 'y';
        }
        else {
            TAEB->debug("Floor-food $food is on the blacklist. Pass.");
        }
    }

    # we're specific about this. really
    return 'y' if $food->identity eq $self->food;

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
        TAEB->error("There's no safe food in my inventory, so I can't eat 'any'. Sending escape, but I doubt this will work.");
    }
    else {
        TAEB->error("Unable to eat '" . $self->food . "'. Sending escape, but I doubt this will work.");
    }
    return "\e";
}

sub done {
    my $self = shift;
    my $food = $self->food;

    # we had no match for "any", so we have nothing to do
    return unless blessed $food;

    if ($food->slot) {
        TAEB->inventory->decrease_quantity($food->slot)
    }
    else {
        TAEB->enqueue_message('remove_floor_item' => $food);
    }

    my $old_nutrition = TAEB->senses->nutrition;
    my $new_nutrition = $old_nutrition + $food->nutrition;

    TAEB->debug("Eating $food is increasing our nutrition from $old_nutrition to $new_nutrition");
    TAEB->senses->nutrition($new_nutrition);
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

sub exception_missing_item {
    my $self = shift;
    TAEB->debug("We don't have item " . $self->food . ", escaping.");
    TAEB->inventory->remove($self->food->slot);
    $self->aborted(1);
    return "\e";
}

make_immutable;
no Moose;

1;


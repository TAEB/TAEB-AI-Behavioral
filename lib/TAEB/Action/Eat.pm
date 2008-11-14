#!/usr/bin/env perl
package TAEB::Action::Eat;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Item';
use List::MoreUtils 'any';

use constant command => "e";

has '+item' => (
    isa => 'TAEB::World::Item::Food | Str',
    required => 1,
);

sub respond_eat_ground {
    my $self = shift;
    my $item = TAEB->new_item(shift);

    # no, we want to eat something in our inventory
    return 'n' if blessed $self->item;

    if ($self->item eq 'any') {
        if (TAEB::Spoilers::Item::Food->should_eat($item)) {
            TAEB->debug("Floor-food $item is good enough for me.");
            # keep track of what we're eating for nutrition purposes later
            $self->item($item);
            TAEB->enqueue_message('check', 'floor');
            return 'y';
        }
        else {
            TAEB->debug("Floor-food $item is on the blacklist. Pass.");
        }
    }

    # we're specific about this. really
    if ($item->match(identity => $self->item)) {
        TAEB->enqueue_message('check', 'floor');
        return 'y';
    }

    # no thanks, I brought my own lunch
    return 'n';
}

sub respond_eat_what {
    my $self = shift;
    return $self->item->slot if blessed($self->item);

    if ($self->item eq 'any') {
        my $item = TAEB->find_item(sub { $self->can_eat(@_) });

        if ($item) {
            $self->item($item);
            return $item->slot;
        }
        TAEB->error("There's no safe food in my inventory, so I can't eat 'any'. Sending escape, but I doubt this will work.");
    }
    else {
        TAEB->error("Unable to eat '" . $self->item . "'. Sending escape, but I doubt this will work.");
    }

    TAEB->enqueue_message(check => 'inventory');
    TAEB->enqueue_message(check => 'floor');
    $self->aborted(1);
    return "\e\e\e";
}

sub post_responses {
    my $self = shift;
    my $item = $self->item;

    if (blessed $item && $item->slot)  {
        TAEB->inventory->decrease_quantity($item->slot)
    }
    else {
        $item = TAEB->new_item($item);
    }

    my $old_nutrition = TAEB->nutrition;
    my $new_nutrition = $old_nutrition + $item->nutrition;

    TAEB->debug("Eating $item is increasing our nutrition from $old_nutrition to $new_nutrition");
    TAEB->nutrition($new_nutrition);
}

# is there any food around?
sub any_food {
    my $self = shift;

    return any { $self->can_eat($_) }
           TAEB->current_tile->items,
           TAEB->inventory->items;
}

sub can_eat {
    my $self = shift;
    my $item = shift;

    return 0 unless $item->class eq 'food' || $item->class eq 'carrion';
    return 0 unless TAEB::Spoilers::Item::Food->should_eat($item);
    return 0 if $item->match(identity => 'lizard corpse')
             && TAEB->nutrition > 5;
    return 1;
}

before exception_missing_item => sub {
    my $self = shift;
    if ($self->item eq 'any') {
        TAEB->enqueue_message(check => 'inventory');
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


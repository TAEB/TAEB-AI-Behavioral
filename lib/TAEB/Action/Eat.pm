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
            TAEB->log->action("Floor-food $item is good enough for me.");
            # keep track of what we're eating for nutrition purposes later
            $self->item($item);
            return 'y';
        }
        else {
            TAEB->log->action("Floor-food $item is on the blacklist. Pass.");
        }
    }

    # we're specific about this. really
    return 'y' if $item->match(identity => $self->item);

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
        TAEB->log->action("There's no safe food in my inventory, so I can't eat 'any'. Sending escape, but I doubt this will work.", level => 'error');
    }
    else {
        TAEB->log->action("Unable to eat '" . $self->item . "'. Sending escape, but I doubt this will work.", level => 'error');
    }

    TAEB->enqueue_message(check => 'inventory');
    TAEB->enqueue_message(check => 'floor');
    $self->aborted(1);
    return "\e\e\e";
}

sub msg_stopped_eating {
    my $self = shift;
    my $item = shift;

    #when we stop eating, check inventory or the floor for the "partly"
    #eaten leftovers.  post_responses will take care of removing the original
    #item from inventory
    my $what = (blessed $item && $item->slot) ? 'inventory' : 'floor';
    TAEB->log->action("Stopped eating $item from $what");
    TAEB->enqueue_message(check => $what);

    return;
}

sub post_responses {
    my $self = shift;
    my $item = $self->item;

    if (blessed $item && $item->slot)  {
        TAEB->inventory->decrease_quantity($item->slot)
    }
    elsif ($item eq 'any') {
        #we had some issues, and none of the responses were called. bail out.
        TAEB->log->action("Tried to eat food but no responses were called",
                          level => 'warning');
        return;
    }
    else {
        $item = TAEB->new_item($item);
        #This doesn't work well with a stack of corpses on the floor
        #because maybe_is used my remove_floor_item tries to match quantity
        TAEB->enqueue_message(remove_floor_item => $item);
    }

    my $old_nutrition = TAEB->nutrition;
    my $new_nutrition = $old_nutrition + $item->nutrition;

    TAEB->log->action("Eating $item is increasing our nutrition from $old_nutrition to $new_nutrition");
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

sub overfull {
    # make sure we don't eat anything until we stop being satiated
    TAEB->nutrition(5000);
}

sub respond_stop_eating { shift->overfull; "y" }

sub msg_finally_finished { shift->overfull }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::Action::Eat;
use Moose;
extends 'TAEB::Action';

use constant command => "e";

has food => (
    is       => 'rw',
    isa      => 'TAEB::World::Item | Str',
    required => 1,
);

sub respond_eat_ground {
    my $self = shift;
    my $msg  = shift;
    my $food = shift;

    # no, we want to eat something in our inventory
    return 'n' if blessed $self->food;

    # XXX: check to see if the item on the ground is kosher to eat
    return 'y' if $self->food eq 'any';

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
            return $try->class eq 'food'; # XXX: and that it's safe to eat
        });
        if ($food) {
            return $food->slot;
        }
        TAEB->error("There's no safe food in my inventory, so I can't eat 'anything'. Sending escape, but I doubt this will work.");
    }
    else {
        TAEB->error("Unable to eat '" . $self->into . "'. Sending escape, but I doubt this will work.");
    }
    return "\e";
}

sub done {
    my $self = shift;
    if (blessed $self->food) {
        TAEB->inventory->decrease_quantity($self->food->slot)
    }
}

make_immutable;

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Shop;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

# for now, we just drop unpaid items

sub prepare {
    my $self = shift;
    my @drop = grep { $_->price } TAEB->inventory->items;

    if (@drop) {
        $self->currently("Dropping items due to having a price.");
        $self->do(drop => items => \@drop);
        return 100;
    }

    return 0;
}

sub drop {
    my $self = shift;
    my $item = shift;

    return $item->price ? 1 : 0;
}

sub urgencies {
    return {
        100 => "dropping an unpaid item",
    }
}

make_immutable;
no Moose;

1;


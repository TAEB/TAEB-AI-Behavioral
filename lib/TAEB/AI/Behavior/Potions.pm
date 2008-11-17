#!/usr/bin/env perl
package TAEB::AI::Behavior::Potions;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) } TAEB->inventory->items;
    return URG_NONE unless @items;

    my $item = shift @items;

    $self->currently("quaffing a beneficial potion");
    $self->do(quaff => from => $item);

    return URG_UNIMPORTANT;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return 1 if $item->match(identity => 'potion of gain ability');
    return 1 if $item->match(identity => 'potion of gain level');
    return 0;

    return 1;
}

sub urgencies {
    return {
       URG_UNIMPORTANT => "quaffing a benefical potion",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


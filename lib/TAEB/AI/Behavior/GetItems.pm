#!/usr/bin/env perl
package TAEB::AI::Behavior::GetItems;
use TAEB::OO;
extends 'TAEB::AI::Behavior';
use List::MoreUtils 'any';

sub prepare {
    my $self = shift;

    my @want = grep { TAEB->want_item($_) } TAEB->current_tile->items;
    if (@want) {
        TAEB->debug("TAEB wants items! @want");
        $self->currently("Picking up items");
        $self->do("pickup");
        return 100;
    }

    my $path = TAEB::World::Path->first_match(sub {
        return any { TAEB->want_item($_) } shift->items;
    });

    $self->if_path($path => "Heading towards an item");
}

sub urgencies {
    return {
        100 => "picking up an item here",
         50 => "path to a new item",
    },
}

make_immutable;
no Moose;

1;


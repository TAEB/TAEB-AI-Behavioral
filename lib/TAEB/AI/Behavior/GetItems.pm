#!/usr/bin/env perl
package TAEB::AI::Behavior::GetItems;
use Moose;
extends 'TAEB::AI::Behavior';

use List::MoreUtils 'any';

sub prepare {
    my $self = shift;

    if (any { TAEB->want_item($_) } TAEB->current_tile->items) {
        $self->next(",");
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

1;


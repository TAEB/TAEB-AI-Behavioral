#!/usr/bin/env perl
package TAEB::AI::Behavior::GetItems;
use Moose;
extends 'TAEB::AI::Behavior';

use List::MoreUtils 'any';

sub prepare {
    my $self = shift;

    return 100 if any { TAEB->want_item($_) } TAEB->current_tile->items;

    my $path = TAEB::World::Path->first_match(sub {
        my $tile = shift;
        return any { TAEB->want_item($_) } $tile->items;
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


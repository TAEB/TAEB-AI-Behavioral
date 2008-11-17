#!/usr/bin/env perl
package TAEB::AI::Behavior::GetItems;
use TAEB::OO;
extends 'TAEB::AI::Behavior';
use List::MoreUtils 'any';

sub prepare {
    my $self = shift;

    # picking up items while blind tends to work very badly
    # e.g. "j - a wand"
    return if TAEB->is_blind;

    my @want = grep { TAEB->want_item($_) } TAEB->current_tile->items;
    if (@want) {
        TAEB->debug("TAEB wants items! @want");
        $self->currently("Picking up items");
        $self->do("pickup");
        $self->urgency('unimportant');
        return;
    }

    return unless TAEB->current_level->has_type('interesting')
               || any { TAEB->want_item($_) } TAEB->current_level->items;

    my $path = TAEB::World::Path->first_match(sub {
        my $tile = shift;

        return if $tile->in_vault;

        if ($tile->in_shop || $tile->in_temple) {
            #this lets taeb go shopping once and keeps from
            #oscillating due to shk leaving LOS on items
            return 0 if $tile->stepped_on || $tile->glyph eq '@';

            # unresolved debt, don't compound it
            return 0 if TAEB->debt > 0;
        }

        # zoos tend to have sleeping peacefuls
        return 0 if $tile->has_monster && $tile->in_zoo;

        return 1 if $tile->is_interesting;
        return any { TAEB->want_item($_) } $tile->items;
    }, why => "GetItems");

    $self->if_path($path => "Heading towards an item");
}

sub urgencies {
    return {
        unimportant => "picking up an item here",
        fallback    => "path to a new item",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


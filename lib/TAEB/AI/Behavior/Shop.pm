#!/usr/bin/env perl
package TAEB::AI::Behavior::Shop;
use TAEB::OO;
use List::MoreUtils 'any';
extends 'TAEB::AI::Behavior';

# for now, we just drop unpaid items

sub prepare {
    my $self = shift;

    if (TAEB->debt > 0) {
        my @cart = grep { $_->price } TAEB->inventory->items;

        if (any { $_->price <= TAEB->gold } @cart) {
            $self->currently("Paying off our " . TAEB->debt . " debt");
            $self->do(pay => item => 'any');
            $self->urgency('unimportant');
            return;
        }

        # every item in our cart is greater than our current gold :(
        if (@cart) {
            $self->currently("Dropping items since I can't afford them");
            $self->do(drop => items => \@cart);
            $self->urgency('unimportant');
            return;
        }
        #try to pay for used item/damages debt
        if (!@cart && TAEB->debt > 0) {
            $self->currently("Paying off our " . TAEB->debt . " debt");
            $self->do(pay => item => 'any');
            $self->urgency('unimportant');
            return;
	}
    }
}

sub drop {
    my $self = shift;
    my $item = shift;

    if (!TAEB->current_tile->in_shop &&
        $item->match(identity => qr/pick-axe|dwarvish mattock/) &&
        TAEB->any_adjacent(sub {
            my $tile = shift;
            return 1 if $tile->has_monster && $tile->monster->is_shk;
            return 0;
        })) {
        return 1;
    }

    return if $item->match(price => 0);

    if ($item->price > TAEB->gold) {
        TAEB->debug("Yes, I want to drop $item because I can't pay for it");
        return 1;
    }
}

sub urgencies {
    return {
        unimportant => "dropping/paying for an unpaid item",
     }
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return if TAEB->current_tile->in_vault || !TAEB->current_tile->in_shop;

    if ($item->price > TAEB->gold) {
        TAEB->debug("Item " . $item . "costs too much to pickup");
        return 0;
    }
    if ($item->match(appearance => 'gold piece')) {
        return 1;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


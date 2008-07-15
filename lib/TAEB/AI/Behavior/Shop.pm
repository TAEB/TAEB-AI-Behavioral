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
            return 90;
        }

        # every item in our cart is greater than our current gold :(
        if (@cart) {
            $self->currently("Dropping items since I can't afford them");
            $self->do(drop => items => \@cart);
            return 100;
        }

        #XXX:  Handle trying to get out of debt by selling stuff if we broke something and can't pay
    }
}

sub drop {
    my $self = shift;
    my $item = shift;

    if (!TAEB->current_tile->in_shop &&
        $item->match(m/pick-axe|dwarvish mattock/) &&
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
        100 => "dropping an unpaid item",
         90 => "paying bills",
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


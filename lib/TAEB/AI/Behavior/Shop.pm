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

    if (TAEB->debt && TAEB->debt <= TAEB->gold) {
        $self->currently("Paying off our " . TAEB->debt . " debt");
        $self->do(pay => item => 'any');
        return 80;
    }

    return 0;
}

sub drop {
    my $self = shift;
    my $item = shift;

    return unless TAEB->current_tile->in_shop;
    return if $item->match(price => 0);

    TAEB->debug("Yes, I want to drop $item because it costs money.");
    return 1;
}

sub urgencies {
    return {
        100 => "dropping an unpaid item",
         80 => "paying bills",
    }
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return 0 if TAEB->current_tile->in_vault;
    return 1 if $item->match(appearance => 'gold piece');
    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Shop;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

# for now, we just drop unpaid items

sub prepare {
    my $self = shift;

    # the shopkeeper just told us we owe him. how much?
    if (!defined(TAEB->senses->debt)) {
        $self->currently("Figuring out how much money we owe");
        $self->do('gold');
        return 100;
    }

    my @drop = grep { $_->price } TAEB->inventory->items;

    if (@drop) {
        $self->currently("Dropping items due to having a price.");
        $self->do(drop => items => \@drop);
        return 90;
    }

    if (TAEB->senses->debt && TAEB->senses->debt <= TAEB->senses->gold) {
        $self->currently("Paying off our " . TAEB->senses->debt . " debt");
        $self->do(pay => item => 'any');
        return 80;
    }

    return 0;
}

sub drop {
    my $self = shift;
    my $item = shift;

    return if $item->price == 0;
    TAEB->debug("Yes, I want to drop $item because it costs money.");
    return 1;
}

sub urgencies {
    return {
        100 => "figuring out how much money we owe",
         90 => "dropping an unpaid item",
         80 => "paying bills",
    }
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return 1 if $item->appearance eq 'gold piece';
    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


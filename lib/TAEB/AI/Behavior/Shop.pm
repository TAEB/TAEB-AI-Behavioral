#!/usr/bin/env perl
package TAEB::AI::Behavior::Shop;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

has debt => (
    isa     => 'Maybe[Int]',
    default => 0,
);

# for now, we just drop unpaid items

sub prepare {
    my $self = shift;

    # the shopkeeper just told us we owe him. how much?
    if (!defined($self->debt)) {
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

    if ($self->debt && $self->debt <= TAEB->senses->gold) {
        $self->currently("Paying off our " . $self->debt . " debt");
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

sub msg_debt {
    my $self = shift;
    my $gold = shift;

    # gold is occasionally undefined. that's okay, that tells us to check
    # how much we owe with the $ command
    $self->debt($gold);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


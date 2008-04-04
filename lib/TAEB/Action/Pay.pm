#!/usr/bin/env perl
package TAEB::Action::Pay;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "p";

has item => (
    isa      => 'TAEB::World::Item | Str',
    required => 1,
    provided => 1,
);

sub respond_buy_item {
    my $self = shift;
    my $item = TAEB->new_item(shift);
    my $cost = shift;

    $item->price($cost);

    if (blessed($self->item) && $self->item->maybe_is($item)) {
        TAEB->info("Buying $item explicitly.");
        return 'y';
    }

    if (!blessed($self->item) && $self->item eq 'any') {
        TAEB->info("Buying $item because we're buying everything.");
        return 'y';
    }

    return 'n';
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


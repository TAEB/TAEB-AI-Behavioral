#!/usr/bin/env perl
package TAEB::Action::Pickup;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => ',';

# the screenscraper currently handles this code. it should be moved here

sub msg_got_item {
    my $self = shift;
    TAEB->enqueue_message(remove_floor_item => @_);
}

sub begin_select_pickup {
    TAEB->enqueue_message('clear_floor');
}

sub select_pickup {
    my $item = TAEB->new_item($_)
        or return;
    TAEB->enqueue_message('floor_item' => $item);
    TAEB->want_item($item);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


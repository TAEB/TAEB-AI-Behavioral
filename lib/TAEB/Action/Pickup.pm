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

__PACKAGE__->meta->make_immutable;
no Moose;

1;


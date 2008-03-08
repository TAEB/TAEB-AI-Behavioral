#!/usr/bin/env perl
package TAEB::Action::Open;
use Moose;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

use constant command => 'o';

sub msg_door {
    my $self = shift;
    my $type = shift;

    $type eq 'locked' or return;

    # mark the door as locked
}

make_immutable;

1;


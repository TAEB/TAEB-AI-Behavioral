#!/usr/bin/env perl
package TAEB::Action::Open;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

use constant command => 'o';

sub msg_door {
    my $self = shift;
    my $type = shift;

    my $tile = $self->target_tile('closeddoor');

    if ($type eq 'locked') {
        $tile->locked('locked');
    }
    elsif ($type eq 'resists') {
        $tile->locked('unlocked');
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


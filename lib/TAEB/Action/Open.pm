#!/usr/bin/env perl
package TAEB::Action::Open;
use Moose;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

use constant command => 'o';

sub msg_door {
    my $self = shift;
    my $type = shift;

    my $tile = TAEB->current_level->at_delta($self->direction);
    unless ($tile->type eq 'closeddoor') {
        TAEB->warning("Tried to change state of a ".$tile->type.". I can only handle closeddoor.");
        return;
    }

    if ($type eq 'locked') {
        $tile->locked('locked');
    }
    elsif ($type eq 'resists') {
        $tile->locked('unlocked');
    }
}

make_immutable;

1;


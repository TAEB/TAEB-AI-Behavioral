#!/usr/bin/env perl
package TAEB::AI::Behavior::FixHunger;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return TAEB->vt->row_plaintext(23) =~ /\bFai/ ? 1000 : 0;
}

sub next_action { "#pray\n" }

sub max_urgency { 1000 }

1;


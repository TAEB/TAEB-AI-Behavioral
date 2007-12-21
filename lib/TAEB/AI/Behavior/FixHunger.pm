#!/usr/bin/env perl
package TAEB::AI::Behavior::FixHunger;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;
    my $urgency = 1000 - TAEB->hunger;

    # start worrying about hunger a little before Hungry (150)
    $urgency = 0 if $urgency < 800;
}

sub next_action { "#pray\n" }

sub max_urgency { 1200 }

1;


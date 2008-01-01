#!/usr/bin/env perl
package TAEB::AI::Behavior::GetItems;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # pick up individual items
    if (TAEB->messages =~ /^You see here (.*?)\./) {
        local $_ = $1;
        if (TAEB->personality->pickup('-')) {
            return 50;
        }
    }

    # things that are here, you see here many things, etc
    return 0;
}

sub next_action { "," }

sub currently { "Picking up items" }

sub weights {
    return {
        100 => "picking up multiple items",
         50 => "picking up one item",
    },
}

1;


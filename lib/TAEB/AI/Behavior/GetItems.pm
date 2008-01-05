#!/usr/bin/env perl
package TAEB::AI::Behavior::GetItems;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # pick up individual items
    if (TAEB->messages =~ /You see here (.*?)\./) {
        local $_ = $1;
        TAEB->debug("Checking whether I want a '$_'.");
        if (TAEB->personality->pickup('-')) {
            TAEB->debug("Yep!");
            return 50;
        }
        TAEB->debug("Nope!");
    }

    # things that are here, you see here many things, etc
    return 0;
}

sub next_action { "," }

sub currently { "Picking up items" }

sub urgencies {
    return {
        100 => "picking up multiple items",
         50 => "picking up one item",
    },
}

1;


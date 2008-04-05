#!/usr/bin/env perl
package TAEB::AI::Personality::Hivemind;
use TAEB::OO;
extends 'TAEB::AI::Personality';

sub next_action {
    TAEB::Action::Custom->new(string => "S");
}

sub respond {
    "\e"
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


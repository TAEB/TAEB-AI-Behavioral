#!/usr/bin/env perl
package TAEB::AI::Personality::Hivemind;
use TAEB::OO;
use TAEB::AI::Personality::Hivemind::Templates;
extends 'TAEB::AI::Personality';

sub next_action {
    $main::request->print(TAEB::AI::Personality::Hivemind::Templates->next_action);
    $main::request->next;
    my $cmd = $main::request->param('c');
    TAEB::Action::Custom->new(string => substr($cmd, 0, 1));
}

sub respond {
    $main::request->print(TAEB::AI::Personality::Hivemind::Templates->respond);
    $main::request->next;
    $main::request->param('c');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


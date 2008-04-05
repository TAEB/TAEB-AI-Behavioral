#!/usr/bin/env perl
package TAEB::AI::Personality::Hivemind;
use TAEB::OO;
extends 'TAEB::AI::Personality';

sub next_action {
    $main::request->print(q{<form><input size=1 maxlength=1 name=c></form><pre>}.TAEB->vt->as_string("\n").q{</pre>});
    $main::request->next;
    my $cmd = $main::request->param('c');
    TAEB::Action::Custom->new(string => substr($cmd, 0, 1));
}

sub respond {
    $main::request->print(q{<form><input name=c></form><pre>}.TAEB->vt->as_string("\n").q{</pre>});
    $main::request->next;
    $main::request->param('c');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


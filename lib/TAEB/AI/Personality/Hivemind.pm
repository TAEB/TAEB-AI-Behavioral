#!/usr/bin/env perl
package TAEB::AI::Personality::Hivemind;
use TAEB::OO;
extends 'TAEB::AI::Personality';

sub next_action {
    $main::request->print('<html><body>');
    $main::request->print('<form><input id="cmd" type="text" size="1" maxlength="1" name="c"></input></form><script>document.getElementById("cmd").focus()</script>');
    $main::request->print('<pre>' . TAEB->vt->as_string("\n") . '</pre>');
    $main::request->print('</body></html>');
    $main::request->next;
    my $c = substr($main::request->param('c'), 0, 1);
    return TAEB::Action->new_action(custom => string => $c);
}

sub respond {
    $main::request->print('<html><body>');
    $main::request->print('<pre>' . TAEB->topline . '</pre>');
    $main::request->print('<form><input id="cmd" type="text" size="20" name="c"></input></form><script>document.getElementById("cmd").focus()</script>');
    $main::request->print('<pre>' . TAEB->vt->as_string("\n", 1) . '</pre>');
    $main::request->print('</body></html>');
    $main::request->next;
    return $main::request->param('c');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


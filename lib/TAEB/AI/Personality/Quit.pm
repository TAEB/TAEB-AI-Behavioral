#!/usr/bin/env perl
package TAEB::AI::Personality::Quit;
use TAEB::OO;
extends 'TAEB::AI::Personality';

=head1 NAME

TAEB::AI::Personality::Quit - I just can't take it any more...

=cut

sub next_action { "#quit\ny" }

make_immutable;

1;


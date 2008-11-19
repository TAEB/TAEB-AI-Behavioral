#!/usr/bin/env perl
package TAEB::AI::Personality::Quit;
use TAEB::OO;
extends 'TAEB::AI::Personality';

=head1 NAME

TAEB::AI::Personality::Quit - I just can't take it any more...

=cut

sub next_action { TAEB::Action->new_action(custom => string => "#quit\ny") }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::AI::Brain::Descender;
use Moose;
extends 'TAEB::AI::Brain';

=head1 NAME

TAEB::AI::Brain::Descender - descend as quickly as sanely possible

=cut

sub autoload_behaviors { qw/Explore FixHunger Descend Search/ }

# we want him flying down stairs
sub weight_descend { 500 }

sub next_action {
    shift->behavior_action;
}

1;


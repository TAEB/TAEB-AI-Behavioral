#!/usr/bin/env perl
package TAEB::AI::Personality::RandomWalk;
use TAEB::OO;
extends 'TAEB::AI::Personality';

=head1 NAME

TAEB::AI::Personality::RandomWalk - 30 kyu, here I come!

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head2 next_action TAEB -> STRING

This will randomly walk in the eight directions. Pays no attention to such
things as 'the map' and 'direction of play'.

=cut

my @actions = (qw(h j k l y u b n), ' ');

sub next_action {
    $self->currently("Randomly walking.");
    return $actions[rand @actions];
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


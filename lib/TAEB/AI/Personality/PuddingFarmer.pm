#!/usr/bin/env perl
package TAEB::AI::Personality::PuddingFarmer;
use TAEB::OO;
extends 'TAEB::AI::Personality::Explorer';

=head1 NAME

TAEB::AI::Personality::PuddingFarmer - the high score is OURS!

=cut

around weight_behaviors => sub {
    my $orig = shift;
    my $weights = $orig->(@_);

    $weights->{GetPudding} = 20_000;

    return $weights;
};

around pickup => sub {
    my $orig = shift;
    my $self = shift;
    my $item = shift;

    return 1 if $item->identity eq 'wand of fire'; # engraving
    return 1 if $item->identity eq 'ring of slow digestion'; # sustenance

    return $orig->($self, $item, @_);
};

1;


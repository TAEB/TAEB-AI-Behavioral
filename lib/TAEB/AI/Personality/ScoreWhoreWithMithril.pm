#!/usr/bin/env perl
package TAEB::AI::Personality::ScoreWhoreWithMithril;
use TAEB::OO;
extends 'TAEB::AI::Personality::ScoreWhore';

around weight_behaviors => sub {
    my $orig = shift;
    my $weights = $orig->(@_);

    $weights->{AcquireMithril} = 24_600;

    return $weights;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


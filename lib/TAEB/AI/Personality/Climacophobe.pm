#!/usr/bin/env perl
package TAEB::AI::Personality::Climacophobe;
use Moose;
extends 'TAEB::AI::Personality::Explorer';

=head1 NAME

TAEB::AI::Personality::Climacophobe - Never use stairs! They make hard monsters spawn!

=cut

around weight_behaviors => sub {
    my $orig = shift;
    my $self = shift;

    my $explorer_weights = $self->$orig(@_);

    delete $explorer_weights->{Descend};

    return $explorer_weights;
}

make_immutable;

1;


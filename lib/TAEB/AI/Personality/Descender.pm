#!/usr/bin/env perl
package TAEB::AI::Personality::Descender;
use TAEB::OO;
extends 'TAEB::AI::Personality::Explorer';

=head1 NAME

TAEB::AI::Personality::Descender - descend as quickly as sanely possible

=cut

around weight_behaviors => sub {
    my $orig = shift;
    my $self = shift;

    my $behaviors = $self->$orig;
    $behaviors->{Descend} = 80_000;

    return $behaviors;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


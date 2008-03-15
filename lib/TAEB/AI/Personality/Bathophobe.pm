#!/usr/bin/env perl
package TAEB::AI::Personality::Bathophobe;
use TAEB::OO;
extends 'TAEB::AI::Personality::Explorer';

=head1 NAME

TAEB::AI::Personality::Bathophobe - Never descend! It makes hard monsters spawn!

=cut

around weight_behaviors => sub {
    my $orig = shift;
    my $self = shift;

    my $explorer_weights = $self->$orig(@_);

    delete $explorer_weights->{Descend};

    # above opening doors but below dipping for Excalibur
    $explorer_weights->{Ascend} = TAEB->z > 1 ? 20_000 : 0;

    return $explorer_weights;
};

make_immutable;

1;


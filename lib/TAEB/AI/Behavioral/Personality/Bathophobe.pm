#!/usr/bin/env perl
package TAEB::AI::Personality::Bathophobe;
use TAEB::OO;
extends 'TAEB::AI::Personality::Explorer';

=head1 NAME

TAEB::AI::Personality::Bathophobe - Never descend! It makes hard monsters spawn!

=cut

after sort_behaviors => sub {
    my $self = shift;

    $self->remove_behavior('Descend');
    $self->add_behavior('Ascend', after => 'DipForExcalibur') if TAEB->z > 1;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


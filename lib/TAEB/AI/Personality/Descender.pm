#!/usr/bin/env perl
package TAEB::AI::Personality::Descender;
use TAEB::OO;
extends 'TAEB::AI::Personality::Explorer';

=head1 NAME

TAEB::AI::Personality::Descender - descend as quickly as sanely possible

=cut

after sort_behaviors => sub {
    my $self = shift;

    $self->remove_behavior('Descend');
    $self->add_behavior('Descend', after => 'Fight');
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


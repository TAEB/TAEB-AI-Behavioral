#!/usr/bin/env perl
package TAEB::AI::Personality::ScoreWhore;
use TAEB::OO;
extends 'TAEB::AI::Personality::Explorer';

=head1 NAME

TAEB::AI::Personality::ScoreWhore - milk each dungeon level for as long as possible

=head1 DESCRIPTION

This personality will avoid descending until its experience level is greater
than its dungeon level, or it spent 1000 turns on the current level.

This is an example of shifting the weight of a behavior around.

=cut

around weight_behaviors => sub {
    my $orig = shift;
    my $self = shift;

    my $behaviors = $self->$orig;

    # Descend at a very leisurely pace
    if (TAEB->level > TAEB->z || TAEB->current_level->turns_spent_on >= 1000) {
        $behaviors->{Descend} = 1000;
    }
    else {
        $behaviors->{Descend} = 2;
    }

    return $behaviors;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::AI::Personality::PickaxeFinder;
use TAEB::OO;
extends 'TAEB::AI::Personality::Descender';

=head1 NAME

TAEB::AI::Personality::PickaxeFinder - get a pickaxe!

=cut

around weight_behaviors => sub {
    my $orig = shift;
    my $behaviors = $orig->(@_);

    # definitely not in the mines, descend!
    return $behaviors if TAEB->z == 1;

    # XXX: shift priorities to get to the mines sooner

    # if we've spent less than 200 turns on the level, stick around
    delete $behaviors->{Descend}
        if TAEB->current_level->turns_spent_on < 200;

    # if we heard a pickaxe sound recently, stick around
    delete $behaviors->{Descend}
        if TAEB->turn < TAEB->current_level->pickaxe + 200;

    return $behaviors;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


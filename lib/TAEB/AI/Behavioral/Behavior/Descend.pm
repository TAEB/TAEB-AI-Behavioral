#!/usr/bin/env perl
package TAEB::AI::Behavior::Descend;
use TAEB::OO;
extends 'TAEB::AI::Behavior::GotoTile';

has stairsdown => (
    isa        => 'ArrayRef[TAEB::World::Tile]',
    auto_deref => 1,
    default    => sub { [] },
);

sub correct_stairs {
    my $self = shift;
    my $tile = shift;

    # not stairs down!
    return 0 unless $tile->type eq 'stairsdown';

    # we only have one choice
    return 1 if @{ $self->stairsdown } == 1;

    # here we have multiple choices and this one is the one we want to avoid.
    # no thank you
    if (my $branch = TAEB->config->avoid_branch) {
        return 0 if $tile->other_side
                 && $tile->other_side->known_branch
                 && $tile->other_side->branch eq $branch;
    }

    return 1;
}

sub match_tile {
    my ($self, $tile) = @_;
    $self->correct_stairs($tile) ? (['descend'], 'Descending', 'fallback')
                                 : undef
}

sub first_pass {
    my @stairsdown = TAEB->current_level->has_type('stairsdown');
    shift->stairsdown(\@stairsdown);
    return @stairsdown;
}

use constant tile_description => 'the downstairs';
use constant using_urgency    => 'descending';

sub urgencies {
    return {
        fallback => 'pathing to or descending a staircase',
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


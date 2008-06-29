#!/usr/bin/env perl
package TAEB::AI::Behavior::Explore;
use TAEB::OO;
extends 'TAEB::AI::Behavior';
use List::MoreUtils 'any';

sub prepare {
    my $self = shift;

    my @exits = grep { !defined($_->other_side) } TAEB->current_level->exits;

    # we don't want to leave the level so quickly if the branch is ambiguous
    @exits = () if !TAEB->current_level->has_branch
                && TAEB->current_level->turns_spent_on < 100;

    my $current = TAEB->current_tile;
    if (any { $current == $_ } @exits) {
        $self->currently("Seeing what's on the other side of this exit");
        if ($current->type eq 'stairsdown') {
            $self->do('descend');
        }
        elsif ($current->type eq 'stairsup') {
            $self->do('ascend');
        }
        else {
            die "I don't know how to handle traversing tile $current!";
        }
        return 100;
    }

    for (@exits) {
        if (my $path = TAEB::World::Path->calculate_path($_)) {
            my $p = $self->if_path($path => "Heading to an unexplored exit", 100);
            return $p if $p;
        }
    }

    my $path = TAEB::World::Path->first_match(sub { not shift->explored });
    $self->if_path($path, "Exploring", 100);
}

sub urgencies {
    return {
        100 => "path to an unexplored square",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Explore;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;
    my $current = TAEB->current_tile;

    if ($current->can('other_side') && !defined($current->other_side)) {
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

    my @exits = grep { !defined($_->other_side) } TAEB->current_level->exits;
    for (@exits) {
        if (my $path = TAEB::World::Path->calculate_path($_)) {
            my $p = $self->if_path($path => "Heading to an explored exit");
            return $p if $p;
        }
    }

    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;
            !$tile->explored && $tile->is_walkable
        },
    );

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


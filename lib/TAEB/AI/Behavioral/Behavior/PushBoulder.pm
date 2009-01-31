#!/usr/bin/env perl
package TAEB::AI::Behavior::PushBoulder;
use TAEB::OO;
use TAEB::Util qw/delta2vi vi2delta/;
extends 'TAEB::AI::Behavior';

sub push_direction {
    my $tile = shift;

    return '.' unless $tile->is_walkable;

    my @tiles = $tile->grep_adjacent(sub {
        my $t = shift;
        my $beyond = $t->level->at($t->x * 2 - $tile->x, $t->y * 2 - $tile->y);
        return 0 unless defined $beyond;
        return 0 unless $t->has_boulder;
        return 0 unless $beyond->type eq 'unexplored';
        return 0 if $beyond->has_monster;
        return 1;
    });
    return '.' unless @tiles;

    return delta2vi($tiles[0]->x - $tile->x, $tiles[0]->y - $tile->y);
}

sub msg_immobile_boulder {
    # The boulder didn't move, there must be rock or another boulder beyond it.
    my ($dx, $dy) = vi2delta(push_direction(TAEB->current_tile));
    TAEB->current_level->at(TAEB->x + $dx * 2,TAEB->y + $dy * 2)->type('rock');
}

sub prepare {
    my $self = shift;

    return if TAEB->current_level->branch eq 'sokoban';

    my $path = TAEB::World::Path->first_match(sub {
            push_direction(shift) ne '.';
        },
        why => "PushBoulder"
    );

    my $push_dir = push_direction(TAEB->current_tile);

    if ($path && $path->path eq '' && $push_dir ne '.') {
        $self->currently("Pushing an adjacent boulder");
        $self->do(move => direction => $push_dir);
        $self->urgency('fallback');
        return;
    }

    $self->if_path($path => "Heading to a pushable edge boulder");
}

sub urgencies {
    return {
        fallback => "pushing or preparing to push a boulder into the unknown",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


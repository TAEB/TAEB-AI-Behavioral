#!/usr/bin/env perl
package TAEB::AI::Behavior::Explore;
use TAEB::OO;
extends 'TAEB::AI::Behavior';
use List::MoreUtils 'any';

sub unexplored_level {
    my $level = shift;
    return 0 if defined TAEB->current_level->exit_towards($level)
                && ($level->exit_towards(TAEB->current_level)->type eq
                TAEB->current_level->exit_towards($level)->type);
    return 0 if $level->z > TAEB->z;
    return not $level->fully_explored;
}

sub prepare {
    my $self = shift;

    my @exits = grep { !defined($_->other_side) } TAEB->current_level->exits;

    # we don't want to leave the level so quickly if the branch is ambiguous
    @exits = () if !TAEB->current_level->known_branch
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
        $self->urgency('fallback');
        return;
    }

    for (@exits) {
        if (my $path = TAEB::World::Path->calculate_path($_, why => "Explore/Exit")) {
            my $p = $self->if_path($path => "Heading to an unexplored exit");
            return if $self->urgency;
        }
    }

    my $curlevel = TAEB->current_level;
    my $level = TAEB->shallowest_level(\&unexplored_level);
    $level ||= TAEB->nearest_level(\&unexplored_level);
    # XXX: this would be nice, but it overrides anything of lower priority
    #$level ||= TAEB->shallowest_level(sub { not shift->fully_explored });

    return if !$level;

    my $path = TAEB::World::Path->first_match(sub { not shift->explored },
                                              why      => "Explore",
                                              on_level => $level);
    if (!$path || length($path->path) == 0) {
        TAEB->current_level->fully_explored(1);
    }
    $self->if_path($path, "Exploring");
}

sub urgencies {
    return {
        fallback => "path to an unexplored square",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


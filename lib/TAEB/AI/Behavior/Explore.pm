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

sub find_path {
    my $self = shift;
    my $path;
    for my $method (qw/shallowest_level nearest_level/) {
        my $level = TAEB->$method(\&unexplored_level);
        # XXX: this would be nice, but it overrides anything of lower priority
        #$level ||= TAEB->$method(sub { not shift->fully_explored });

        next if !$level;

        my $prev_explored = $level->fully_explored;
        $path = TAEB::World::Path->first_match(sub { not shift->explored },
                                               why      => "Explore",
                                               on_level => $level,
                                               intralevel_failure => sub {
                                                   $level->fully_explored(1)
                                               });
        redo if $prev_explored != $level->fully_explored;
        last if $path;
    }
    return $path;
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

    $self->if_path($self->find_path, "Exploring");
}

sub urgencies {
    return {
        fallback => "path to an unexplored square",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


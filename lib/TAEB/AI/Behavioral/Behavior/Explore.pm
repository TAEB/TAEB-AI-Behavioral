package TAEB::AI::Behavioral::Behavior::Explore;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';
use TAEB::Util 'any';

sub unexplored_level {
    my $level = shift;
    my $to = TAEB->current_level->exit_towards($level);
    my $from = $level->exit_towards(TAEB->current_level);
    return 0 if defined $to && defined $from && ($to->type eq $from->type);
    return 0 if $level->z > TAEB->z;
    return not TAEB->ai->fully_explored($level);
}

sub find_path {
    my $self = shift;
    my $path;
    LEVEL: for my $method (qw/shallowest_level farthest_level nearest_level/) {
        my $level = TAEB->$method(\&unexplored_level);
        # XXX: this would be nice, but it overrides anything of lower priority
        #$level ||= TAEB->$method(sub { not shift->fully_explored });

        next if !$level;

        PATHFIND: {
            my $prev_explored = $self->fully_explored($level);
            $path = TAEB::World::Path->first_match(
                sub { shift->unexplored },
                on_level => $level,
                through_unknown => 1,
                intralevel_failure => sub {
                    $self->set_fully_explored($level);
                },
                interlevel_failure => sub {
                    $level = shift;
                    no warnings 'exiting';
                    redo PATHFIND;
                }
            );
            redo LEVEL if $prev_explored != $self->fully_explored($level);
        }
        last if $path;
        last if $level == TAEB->current_level;
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

    if ($current->any_adjacent(sub { shift->type eq 'secretdoor' })) {
        $self->currently("Searching for a secret door");
        $self->do('search');
        $self->urgency('fallback');
        return;
    }

    if (any { $current == $_ } @exits) {
        if ($current->type eq 'stairsdown') {
            $self->currently("Seeing what's on the other side of this exit");
            $self->do(move => direction => '>');
            $self->urgency('fallback');
            return;
        }
        elsif ($current->type eq 'stairsup') {
            if (!$self->ascend_is_blacked_out) {
                $self->currently("Seeing what's on the other side of this exit");
                $self->do(move => direction => '<');
                $self->urgency('fallback');
                return;
            }
        }
        else {
            die "I don't know how to handle traversing tile $current!";
        }
    }

    for (@exits) {
        next if $_->type eq 'stairsup' && $self->ascend_is_blacked_out;
        if (my $path = TAEB::World::Path->calculate_path($_)) {
            my $p = $self->if_path($path => "Heading to an unexplored exit");
            return if $self->urgency;
        }
    }

    $self->if_path($self->find_path, "Exploring");
}

use constant max_urgency => 'fallback';

__PACKAGE__->meta->make_immutable;

1;


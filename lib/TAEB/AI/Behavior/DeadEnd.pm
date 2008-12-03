#!/usr/bin/env perl
package TAEB::AI::Behavior::DeadEnd;
use TAEB::OO;
use TAEB::Util qw/delta2vi/;
extends 'TAEB::AI::Behavior';

sub search_direction {
    my $self = shift;
    my @tiles = TAEB->grep_orthogonal(sub {
        my $tile = shift;
        return 0 unless $tile->type eq 'wall'
                     || $tile->type eq 'rock'
                     || $tile->type eq 'unexplored';
        return $tile->searched <= 30;
    });
    return delta2vi($tiles[0]->x - TAEB->x, $tiles[0]->y - TAEB->y);
}

sub is_dead_end {
    my $check = shift;
    my $rock       = 0;
    my $searched   = 0;
    my $walkable   = 0;
    my $unwalkable = 0;

    # don't treat an unexplored tile as a dead end, we don't
    # know if it is or not
    return 0 unless $check->explored;

    # rearrange these tiles into a loop and double it
    $check->each_orthogonal(sub {
        my $tile = shift;
        if ($tile->type eq 'rock'
         || $tile->type eq 'wall'
         || $tile->type eq 'unexplored') {
            $unwalkable++;
            $rock++ if $tile->type ne 'wall';
            $searched += ($tile->searched > 10) ? 10 : $tile->searched;
        }
        else {
            $walkable++;
        }
    });

    # Handle dead ends as well as crooked halls
    # The wall tiles get converted to 8's when building the tile string

    # 888  8888  88888  ...  
    # #@8  8#@8  88@88  -@-    
    # 888  ##88  #####  888 

    # stop us from searching forever :)
    return 0 if $searched >= $rocks * 10;
    return $walkable <= 1 && $rock >= 1;
}

sub prepare {
    my $self = shift;

    return unless !TAEB->current_level->known_branch
               || TAEB->current_level->branch eq 'dungeons'
               || TAEB->current_level->is_minetown;

    if (is_dead_end(TAEB->current_tile)) {
        if (TAEB->is_blind && TAEB->grep_adjacent(sub { shift->searched == 0 })) {
            $self->do('search', iterations => 1);
        }
        else {
            my $stethoscope = TAEB->find_item('stethoscope');
            if ($stethoscope) {
                $self->do(apply => item => $stethoscope,
                          direction => $self->search_direction);
            }
            else {
                $self->do('search');
            }
        }

        $self->currently('Searching at a dead end');
        $self->urgency('fallback');
        return;
    }

    # We aren't at a dead end; are we next to one?
    my @deadends = TAEB->grep_adjacent(sub {
        my $tile = shift;
        return is_dead_end($tile);
    });
    return unless @deadends;

    my $path = TAEB::World::Path->calculate_path($deadends[0]);
    $self->if_path($path => "Heading to a dead end");
}

sub urgencies {
    return {
        fallback => "searching at or pathing to a dead end",
    },
}

sub pickup {
    my $self = shift;
    my $item = shift;
    return $item->match(identity => 'stethoscope');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


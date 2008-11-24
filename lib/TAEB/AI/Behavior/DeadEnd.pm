#!/usr/bin/env perl
package TAEB::AI::Behavior::DeadEnd;
use TAEB::OO;
use TAEB::Util qw/delta2vi/;
extends 'TAEB::AI::Behavior';

sub search_direction {
    my $self = shift;
    my @tiles = TAEB->grep_orthogonal(sub {
        my $t = shift;
        return 0 unless $t->type eq 'wall'
                     || $t->type eq 'rock'
                     || $t->type eq 'unexplored';
        return 0 if $t->searched > 30;
        return 1;
    });
    return delta2vi($tiles[0]->x - TAEB->x, $tiles[0]->y - TAEB->y);
}

sub prepare {
    my $self = shift;

    my $rocks    = 0;
    my $searched = 0;
    my $walkable = 0;

    return unless !TAEB->current_level->known_branch
               || TAEB->current_level->branch eq 'dungeons'
               || TAEB->current_level->is_minetown;

    # rearrange these tiles into a loop and double it
    TAEB->each_orthogonal(sub {
        my $tile = shift;
        if ($tile->type eq 'rock'
         || $tile->type eq 'wall'
         || $tile->type eq 'unexplored') {
            $rocks++;
            $searched += ($tile->searched > 10) ? 10 : $tile->searched;
        }
        else {
            $walkable++;
        }
    });

    # stop us from searching forever :)
    return if $searched >= $rocks * 10;

    # Handle dead ends as well as crooked halls
    # The wall tiles get converted to 8's when building the tile string

    # 888  8888  88888  ...  
    # #@8  8#@8  88@88  -@-    
    # 888  ##88  #####  888 

    # Dead end

    return if $walkable > 1;

    my $stethoscope = TAEB->find_item('stethoscope');
    if (TAEB->is_blind && TAEB->grep_adjacent(sub { shift->searched == 0 })) {
        $self->do('search', iterations => 1);
    }
    else {
        if ($stethoscope) {
            $self->do(apply => item      => $stethoscope,
                               direction => $self->search_direction);
        }
        else {
            $self->do('search');
        }
    }

    $self->urgency('fallback');
}

sub currently { "Searching at a dead end" }

sub urgencies {
    return {
        fallback => "searching at a dead end",
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


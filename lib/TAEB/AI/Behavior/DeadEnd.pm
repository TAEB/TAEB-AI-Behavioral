#!/usr/bin/env perl
package TAEB::AI::Behavior::DeadEnd;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my $rocks    = 0;
    my $searched = 0;
    my $walkable = 0;

    return 0 unless TAEB->current_level->known_branch
                 || TAEB->current_level->branch eq 'dungeons'
                 || TAEB->current_level->is_minetown;

    # rearrange these tiles into a loop and double it
    TAEB->each_orthogonal(sub {
        my $tile = shift;
        if ($tile->type eq 'rock' || $tile->type eq 'wall') {
            $rocks++;
            $searched += $tile->searched;
        }
        else {
            $walkable++;
        }
    });

    # stop us from searching forever :)
    return 0 if $searched >= $rocks * 10;

    # Handle dead ends as well as crooked halls
    # The wall tiles get converted to 8's when building the tile string

    # 888  8888  88888  ...  
    # #@8  8#@8  88@88  -@-    
    # 888  ##88  #####  888 

    # Dead end

    return 0 if $walkable > 1;

    if (TAEB->is_blind) {
        $self->do('search', iterations => 1);
    }
    else {
        $self->do('search');
    }

    return 100;
}

sub currently { "Searching at a dead end" }

sub urgencies {
    return {
        100 => "searching at a dead end",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


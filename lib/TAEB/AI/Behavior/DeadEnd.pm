#!/usr/bin/env perl
package TAEB::AI::Behavior::DeadEnd;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my $tiles;
    my $rocks    = 0;
    my $searched = 0;

    # rearrange these tiles into a loop and double it
    TAEB->each_orthogonal(sub {
        my $tile = shift;
        if ($tile->type eq 'rock' || $tile->type eq 'wall') {
            $tiles .= '8';
            $rocks++;
            $searched += $tile->searched;
        }
        else {
            $tiles .= $tile->glyph;
        }
    });
    $tiles x= 2;

    # stop us from searching forever :)
    return 0 if $searched >= $rocks * 10;

    # Handle dead ends as well as crooked halls
    # The wall tiles get converted to 8's when building the tile string

    # 888  8888  88888  ...  
    # #@8  8#@8  88@88  -@-    
    # 888  ##88  #####  888 

    # Dead end

    return 0 unless $tiles =~ /888/;

    $self->do('search');
    return 100;
}

sub currently { "Searching at a dead end" }

sub urgencies {
    return {
        100 => "searching at a dead end",
    },
}

make_immutable;

1;


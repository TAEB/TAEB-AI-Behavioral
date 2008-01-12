#!/usr/bin/env perl
package TAEB::AI::Behavior::DeadEnd;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my $tiles;
    my $rocks    = 0;
    my $searched = 0;

    TAEB->each_adjacent(sub {
            my $tile = shift;
            $tiles .= ($tile->type =~ /rock|wall/) ? '8' : $tile->glyph;
            $rocks++    if $tile->type =~ /rock/;
            $searched+= $tile->searched if $tile->type =~ /rock|wall/;
        });
    # rearrange these tiles into a loop and double it
    # XXX:function that returns tiles clockwise/counterclockwise would be great
    $tiles = (($1.$3.reverse($4).$2) x 2) if $tiles =~ '(...)(.)(.)(...)';

    #stop us from searching forever :)
    return 0 if $searched >= $rocks * 10;

    # Handle dead ends as well as crooked halls
    # The wall tiles get converted to 8's when building the tile string

    # 888  8888  88888  ...  
    # #@8  8#@8  88@88  -@-    
    # 888  ##88  #####  888 

    # Dead end
    return 100 if $rocks > 6;

    # I'm looking for 5 contiguious rocks and at least 2 wall or floor
    # $rocks > 2 keeps me from searching in the corner of a walled room.
    return 100 if ($tiles =~ /88888/) &&
                    ($tiles =~ /\.\./ || $tiles =~ /##/) && ($rocks > 2);

    return 0;
}

sub next_action {
    my $self = shift;

    # begin the search
    $self->currently("Searching at a dead end");
    TAEB->current_tile->each_neighbor(sub {
        my $self = shift;
        $self->searched($self->searched + 10);
    });

    return '10s';
}

sub urgencies {
    return {
        100 => "searching at a dead end",
    },
}

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Ascend;
use Moose;
extends 'TAEB::AI::Behavior::GotoTile';

sub match_tile {
    shift->floor_glyph eq '<' ? ('<', 'Ascending') : undef
}

use constant tile_description => 'the upstairs';
use constant using_urgency    => 'ascending';

make_immutable;

1;



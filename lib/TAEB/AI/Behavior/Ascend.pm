#!/usr/bin/env perl
package TAEB::AI::Behavior::Ascend;
use Moose;
extends 'TAEB::AI::Behavior::GotoTile';

sub match_tile {
    $_[1]->floor_glyph eq '<' ? (['ascend'], 'Ascending') : undef
}

use constant tile_description => 'the upstairs';
use constant using_urgency    => 'ascending';

make_immutable;

1;



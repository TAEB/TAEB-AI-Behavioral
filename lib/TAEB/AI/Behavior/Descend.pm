#!/usr/bin/env perl
package TAEB::AI::Behavior::Descend;
use TAEB::OO;
extends 'TAEB::AI::Behavior::GotoTile';

sub match_tile {
    $_[1]->floor_glyph eq '>' ? (['descend'], 'Descending') : undef
}

sub first_pass { TAEB->current_level->has_type('stairsdown') }

use constant tile_description => 'the downstairs';
use constant using_urgency    => 'descending';

__PACKAGE__->meta->make_immutable;
no Moose;

1;


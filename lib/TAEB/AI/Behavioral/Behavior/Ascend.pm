package TAEB::AI::Behavioral::Behavior::Ascend;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior::GotoTile';

sub match_tile {
    $_[1]->type eq 'stairsup' ? (['ascend'], 'Ascending', 'fallback') : undef
}

sub first_pass { TAEB->current_level->has_type('stairsup') }

use constant tile_description => 'the upstairs';
use constant using_urgency    => 'ascending';

__PACKAGE__->meta->make_immutable;
no Moose;

1;



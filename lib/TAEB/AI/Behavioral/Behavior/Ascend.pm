package TAEB::AI::Behavioral::Behavior::Ascend;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior::GotoTile';

sub match_tile {
    my ($self, $tile) = @_;

    return undef unless $tile->type eq 'stairsup';
    return undef if $self->ascend_is_blacked_out;

    return ([move => direction => '<'], 'Ascending', 'fallback');
}

sub first_pass { TAEB->current_level->has_type('stairsup') }

use constant tile_description => 'the upstairs';
use constant using_urgency    => 'ascending';

use constant max_urgency => 'fallback';

__PACKAGE__->meta->make_immutable;

1;



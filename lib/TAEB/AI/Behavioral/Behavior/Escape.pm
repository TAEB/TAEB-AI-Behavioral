package TAEB::AI::Behavioral::Behavior::Escape;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior::GotoTile';

sub first_pass {
    return unless = TAEB->current_level->has_type('stairsup');
}

sub prepare {
    my $self = shift;

    if (TAEB->hp * 4 <= TAEB->maxhp) {
        if (TAEB->z > 1) {
            $self->urgency('important');
            $self->currently("Fleeing upstairs to rest.");
            $self->do('ascend');
            return;
        }
    }
}


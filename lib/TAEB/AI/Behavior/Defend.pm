#!/usr/bin/env perl
package TAEB::AI::Behavior::Defend;
use TAEB::OO;
extends 'TAEB::AI::Behavior';
use Scalar::Defer 'lazy';

sub prepare {
    my $self = shift;

    if (TAEB->hp * 2 <= TAEB->maxhp) {
        my $can_engrave = TAEB->can_engrave;
        my $elbereths   = lazy { TAEB->elbereth_count };

        my ($adjacent_ignoring, $adjacent_respecting) = (0, 0);
        TAEB->each_adjacent(sub {
            my $monster = shift->monster or return;
            return unless $monster->is_enemy;

            $monster->respects_elbereth
                ? ++$adjacent_respecting
                : ++$adjacent_ignoring
        });

        # if there's an adjacent monster that ignores Elbereth, then we only
        # write Elbereth if there's no Elbereth on the ground AND there's an
        # adjacent Elbereth-respecting monster. we don't rest on Elbereth
        if ($adjacent_ignoring) {
            if ($can_engrave && $adjacent_respecting && $elbereths == 0) {
                $self->write_elbereth(add_engraving => $elbereths ? 1 : 0);
                $self->urgency('normal');
            }
            return;
        }

        # otherwise, we write Elbereth if we can and there's not already an
        # excessive amount of them
        if ($can_engrave && $elbereths < 3) {
            $self->write_elbereth(add_engraving => $elbereths ? 1 : 0);
            $self->urgency('normal');
            return;
        }

        # finally, we have an Elbereth under us, so we rest up to heal
        if ($elbereths) {
            if (TAEB->current_tile->type eq 'stairsup' && TAEB->z > 1) {
                $self->currently("Fleeing upstairs to rest.");
                $self->do('ascend');
                $self->urgency('unimportant');
                return;
            }
            $self->currently("Resting on an Elbereth tile.");
            $self->do('search', iterations => 5);
            $self->urgency('unimportant');
            return;
        }
    }
    if (TAEB->hp * 4 <= TAEB->maxhp * 3 && !TAEB->current_level->has_enemies) {
        $self->currently("Resting up to gain some hp");
        $self->do('search');
        $self->urgency('unimportant');
        return;
    }
}

sub urgencies {
    return {
       important   => "leaving the area due to low HP",
       normal      => "writing Elbereth due to low HP",
       unimportant => "resting to regain hp before continuing",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


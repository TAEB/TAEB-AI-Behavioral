#!/usr/bin/env perl
package TAEB::AI::Behavior::Melee;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    if (TAEB->is_engulfed) {
        $self->do(melee => direction => 'j');
        $self->currently("Attacking our engulfer.");
        return URG_NORMAL;
    }

    return URG_NONE unless TAEB->current_level->has_enemies;

    # if there's an adjacent monster, attack it
    my $found_monster;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        if ($tile->has_enemy && $tile->monster->is_meleeable) {
            my $action = 'melee';
            if ($tile->monster->is_ghost && TAEB->level < 10
                                         && !TAEB->find_item('Excalibur')) {
                $action = 'kick';
            }

            $self->do($action => direction => $dir);
            $self->currently("Attacking a " . $tile->glyph);
            $found_monster = 1;
        }
    });
    return URG_NORMAL if $found_monster;

    # look for the nearest tile with a monster
    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;
            $tile->has_enemy &&
            $tile->monster->is_meleeable &&
           !$tile->monster->is_seen_through_warning
        },
        through_unknown => 1,
        include_endpoints => 1,
        why => "Melee/Close",
    );

    $self->if_path($path =>
        sub { "Heading towards a " . $path->to->glyph . " monster" });
}

sub urgencies {
    return {
        URG_NORMAL,   "attacking an adjacent monster",
        URG_FALLBACK, "path to the nearest monster",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


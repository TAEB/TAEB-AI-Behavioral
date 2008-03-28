#!/usr/bin/env perl
package TAEB::AI::Behavior::Melee;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return 0 unless TAEB->current_level->has_monsters;

    # if there's an adjacent monster, attack it
    my $found_monster;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        if ($tile->has_enemy && $tile->monster->is_meleeable) {
            $self->do(melee => direction => $dir);
            $self->currently("Attacking a " . $tile->glyph);
            $found_monster = 1;
        }
    });
    return 100 if $found_monster;

    # look for the nearest tile with a monster
    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;
            $tile->has_enemy && $tile->monster->is_meleeable
        },
        through_unknown => 1,
    );

    $self->if_path($path =>
        sub { "Heading towards a " . $path->to->glyph . " monster" });
}

sub urgencies {
    return {
        100 => "attacking an adjacent monster",
         50 => "path to the nearest monster",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Fight;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # if there's an adjacent monster, attack it
    my $found_monster;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        if ($tile->has_monster) {
            $self->do(melee => direction => $dir);
            $self->currently("Attacking a " . $tile->glyph);
            $found_monster = 1;
        }
    });
    return 100 if $found_monster;

    # look for the nearest tile with a monster
    my $path = TAEB::World::Path->first_match(
        sub { shift->has_monster },
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

make_immutable;

1;


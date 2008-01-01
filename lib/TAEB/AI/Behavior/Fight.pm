#!/usr/bin/env perl
package TAEB::AI::Behavior::Fight;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # if we're at 50% health or less and we can write Elbereth, do it
    if (TAEB->hp * 2 < TAEB->maxhp && !TAEB->senses->in_wereform) {
        $self->currently("Writing Elbereth.");
        $self->commands(["E-  Elbereth\n"]);
        return 100;
    }

    # if there's an adjacent monster, attack it
    my $found_monster;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        if ($tile->has_monster) {
            $self->commands([$dir]);
            $self->currently("Attacking a " . $tile->glyph);
            $found_monster = 1;
        }
    });
    return 90 if $found_monster;

    # shortcut: if nothing on the map looks like a monster, don't do pathfinding
    return 0 unless TAEB->map_like(qr/[a-zA-Z~&';:]/);

    # look for the nearest tile with a monster
    my $path = TAEB::World::Path->first_match(
        sub { shift->has_monster },
    );

    # there's a monster on the map, but we don't know how to reach it
    return 0 unless $path && $path->path;

    $self->currently("Heading towards a " . $path->to->glyph . " monster");
    $self->path($path);

    return 50;
}

sub weights {
    return {
        100 => "writing Elbereth",
         90 => "attacking an adjacent monster",
         50 => "path to the nearest monster",
    },
}

1;


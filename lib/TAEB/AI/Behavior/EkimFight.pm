#!/usr/bin/env perl
package TAEB::AI::Behavior::EkimFight;
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

    # if there's no monster nearby, then we don't have anything to do
    # shortcut: if nothing on the map looks like a monster, don't do pathfinding
    return 0 unless TAEB->map_like(qr/[a-zA-Z~&';:]/);

    # look for the nearest tile with a monster
    # XXX: this must be a walking distance, not teleport or something
    my $path = TAEB::World::Path->first_match(
        sub { shift->has_monster },
    );

    # there's a monster on the map, but we don't know how to reach it
    return 0 unless $path && $path->path;

    # monster is far enough away to be insignificant
    return 0 if length($path->path) > 8;

    # if we have fewer than three Elbereths, write another
    if (TAEB->current_tile->elbereths < 3) {
        $self->commands(["E-  Elbereth\n"]);
        $self->currently("Writing Elbereth in preparation for combat,");
        return 80;
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
    return 75 if $found_monster;

    # not sure what happened, so just write Elbereth
    $self->commands(["E-  Elbereth\n"]);
    $self->currently("Writing Elbereth in preparation for combat,");
    return 80;
}

sub weights {
    return {
        100 => "writing Elbereth due to low HP",
         80 => "writing Elbereth in preparation for combat",
         75 => "attacking a monster with Elbereth",
    },
}

1;


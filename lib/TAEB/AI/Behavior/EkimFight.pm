#!/usr/bin/env perl
package TAEB::AI::Behavior::EkimFight;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

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
        $self->write_elbereth;
        $self->currently("Writing Elbereth in preparation for combat.");
        return 100;
    }

    # if there's an adjacent monster, attack it
    my $found_monster;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        if ($tile->has_monster) {
            $self->next($dir);
            $self->currently("Attacking a " . $tile->glyph);
            $found_monster = 1;
        }
    });
    return 75 if $found_monster;

    # not sure what happened, so just write Elbereth
    $self->write_elbereth;
    $self->currently("Writing Elbereth in preparation for combat.");
    return 100;
}

sub urgencies {
    return {
        100 => "writing Elbereth in preparation for combat",
         75 => "attacking a monster with Elbereth",
    },
}

1;


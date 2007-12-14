#!/usr/bin/env perl
package TAEB::AI::Brain::NHackBot;
use Moose;
extends 'TAEB::AI::Brain';

=head1 NAME

TAEB::AI::Brain::NHackBot - Know thy roots

=cut

sub next_action {
    my $self = shift;

    if ($main::taeb->vt->row_plaintext(23) =~ /Fain/) {
        $self->currently("Praying for satiation.");
        return "#pray\n";
    }

    my $fight;

    $self->each_adjacent(sub {
        my ($tile, $dir) = @_;
        $fight = $dir
            if $tile->has_monster;
    });

    $self->currently("Attacking a monster."),
        return $fight
            if $fight;

    # kick down doors
    $self->each_adjacent(sub {
        my ($tile, $dir) = @_;
        if ($tile->glyph eq ']') {
            $fight = chr(4) . $dir;
        }
    });

    $self->currently("Kicking down a door."),
        return $fight
            if $fight;

    # track down monsters
    # XXX: this ignores @ due to annoyance
    if ($main::taeb->map_like(qr/[a-zA-Z~&';:]/)) {
        my ($to, $path) = TAEB::World::Path->first_match_level(
            sub { shift->has_monster },
        );

        if ($path) {
            $self->currently("Heading towards a @{[$to->glyph]} monster.");
            return substr($path, 0, 1);
        }
    }

    # track down doors
    if ($main::taeb->map_like(qr/\]/)) {
        my ($to, $path) = TAEB::World::Path->first_match_level(
            sub { shift->glyph eq ']' },
        );

        if ($path) {
            $self->currently("Heading towards a door.");
            return substr($path, 0, 1);
        }
    }

    # explore
    my ($to, $path) = TAEB::World::Path->first_match_level(
        sub {
            my $tile = shift;
            !$tile->explored && $tile->is_walkable
        },
    );

    if ($path) {
        $self->currently("Exploring.");
        return substr($path, 0, 1);
    }

    # if we're on a >, go down
    if ($main::taeb->current_tile->floor_glyph eq '>') {
        $self->currently("Descending.");
        return '>';
    }

    # if there's a >, go to it
    if ($main::taeb->map_like(qr/>/)) {
        ($to, $path) = TAEB::World::Path->first_match_level(
            sub { shift->floor_glyph eq '>' },
        );

        if ($path) {
            $self->currently("Heading towards stairs.");
            return substr($path, 0, 1);
        }
    }

    # search
    ($to, $path) = TAEB::World::Path->max_match_level(
        sub {
            my ($tile, $path) = @_;
            return undef if $tile->type ne 'wall';
            return 1 / (($tile->searched + length $path) || 1);
        },
    );

    if ($path) {
        $self->currently("Heading towards a search hotspot.");
        return substr($path, 0, 1);
    }

    $self->currently("Searching the adjacent walls.");
    $main::taeb->current_tile->each_neighbor(sub {
        my $self = shift;
        $self->searched($self->searched + 1);
    });

    return 's';
}


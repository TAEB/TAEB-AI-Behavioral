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
        return "#pray\n";
    }

    my $fight;

    $self->each_adjacent(sub {
        my (undef, $tile, $dir) = @_;
        if ($tile->has_monster) {
            $main::taeb->info("Avast! I see a ".$tile->glyph." monster in the $dir direction.");
            $fight = $dir;
        }
    });

    return $fight
        if $fight;

    # kick down doors
    $self->each_adjacent(sub {
        my (undef, $tile, $dir) = @_;
        if ($tile->type eq 'door' && $tile->floor_glyph eq ']') {
            $main::taeb->info("Oh dear! I see a wood board monster in the $dir direction.");
            $fight = chr(4) . $dir;
        }
    });

    return $fight
        if $fight;

    # track down monsters
    # XXX: this ignores @ due to annoyance
    if ($main::taeb->map_like(qr/[a-zA-Z~&';:]/)) {
        my ($to, $path) = TAEB::World::Path->first_match_level(
            $main::taeb->current_tile,
            sub { shift->has_monster },
        );

        if ($path) {
            $main::taeb->info("I've got a bone to pick with a " . $to->glyph . "! $path");
            return substr($path, 0, 1);
        }
    }

    # explore
    my ($to, $path) = TAEB::World::Path->first_match_level(
        $main::taeb->current_tile,
        sub {
            my ($tile, $path) = @_;
            return $tile->stepped_on == 0 && length $path;
        },
    );

    if ($path) {
        $main::taeb->info("Exploring! $path");
        return substr($path, 0, 1);
    }

    # if we're on a >, go down
    if ($main::taeb->current_tile->floor_glyph eq '>') {
        $main::taeb->info("Descending!");
        return '>';
    }

    # if there's a >, go to it
    if ($main::taeb->map_like(qr/>/)) {
        ($to, $path) = TAEB::World::Path->first_match_level(
            $main::taeb->current_tile,
            sub { shift->floor_glyph eq '>' },
        );

        if ($path) {
            $main::taeb->info("Heading to the stairs: $path");
            return substr($path, 0, 1);
        }
    }

    # search
    ($to, $path) = TAEB::World::Path->max_match_level(
        $main::taeb->current_tile,
        sub {
            my ($tile, $path) = @_;
            return undef if $tile->type ne 'wall';
            return 1 / (($tile->searched + length $path) || 1);
        },
    );

    if ($path) {
        $main::taeb->info("Searching! $path");
        return substr($path, 0, 1);
    }

    $main::taeb->current_tile->each_neighbor(sub {
        my $self = shift;
        $self->searched($self->searched + 1);
    });

    return 's';
}


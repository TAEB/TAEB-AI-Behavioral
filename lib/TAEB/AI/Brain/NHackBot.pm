#!/usr/bin/env perl
package TAEB::AI::Brain::NHackBot;
use Moose;
extends 'TAEB::AI::Brain';

=head1 NAME

TAEB::AI::Brain::NHackBot - Know thy roots

=cut

sub next_action {
    my $self = shift;
    my $taeb = shift;

    my $fight;

    $self->each_adjacent(sub {
        my (undef, $taeb, $tile, $dir) = @_;
        if ($tile->has_monster) {
            $taeb->info("Avast! I see a ".$tile->glyph." monster in the $dir direction.");
            $fight = $dir;
        }
    });

    return $fight
        if $fight;

    # explore
    my ($to, $path) = TAEB::World::Path->first_match_level(
        $taeb->current_tile,
        sub {
            my ($tile, $path) = @_;
            return $tile->stepped_on == 0 && length $path;
        },
    );

    if ($path) {
        $taeb->info("Exploring! $path");
        return substr($path, 0, 1);
    }

    # search
    ($to, $path) = TAEB::World::Path->max_match_level(
        $taeb->current_tile,
        sub {
            my ($tile, $path) = @_;
            return undef if $tile->type ne 'wall';
            return 1 / (($tile->searched + length $path) || 1);
        },
    );

    if ($path) {
        $taeb->info("Searching! $path");
        return substr($path, 0, 1);
    }


    $self->current_tile->each_neighbor(sub {
        my $self = shift;
        $self->searched($self->searched + 1);
    });

    return 's';
}


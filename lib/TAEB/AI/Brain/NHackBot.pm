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

    my ($to, $path) = TAEB::World::Path->first_match_level(
        $taeb->current_tile,
        sub {
            my ($tile, $path) = @_;
            return $tile->stepped_on == 0 && length $path;
        },
    );

    return substr($path, 0, 1) || ' ';
}


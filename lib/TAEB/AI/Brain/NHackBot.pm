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

    my @possibilities;
    $self->each_adjacent(sub {
        my (undef, $taeb, $tile, $dir) = @_;
        if ($tile->is_walkable) {
            push @possibilities, $dir;
        }
    });
    $taeb->info("Possible movements: @possibilities");

    return $possibilities[rand @possibilities] || (rand(2) < 1 ? ' ' : '.');
}


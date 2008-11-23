#!/usr/bin/env perl

package TAEB::AI::Behavior::MakeNoise;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return if !TAEB->can_kick;

    my @enemies = grep { $_->in_los } TAEB->current_level->has_enemies;

    my @beckon = grep {
           $_->is_hostile
        && $_->would_chase
        && $_->probably_sleeping
        && $_->distance < sqrt(20 * TAEB->level)
    } @enemies;

    return if @beckon < 10;

    TAEB->current_tile->each_adjacent(sub {
        my ($tile, $dir) = @_;

        return if $tile->item_count;
        return if $tile->has_monster;
        return if $tile->type =~ /throne|altar|tree|fountain|sink|closeddoor/;
        return if $tile->type =~ /wall|unexplored|rock|grave|ironbars|stairs/
               && TAEB->hp < 50;

        $self->currently("Kicking a " . $tile->type . " to wake up a " .
            ($beckon[0]->spoiler || { name => "monster" })->{name} . ".");
        $self->urgency('normal');
        $self->do(kick => direction => $dir);
    });
}

sub urgencies {
    return {
        normal => "Kicking something to make noise",
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


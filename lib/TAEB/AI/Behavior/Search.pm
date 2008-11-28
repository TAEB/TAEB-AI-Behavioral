#!/usr/bin/env perl
package TAEB::AI::Behavior::Search;
use TAEB::OO;
use TAEB::Util qw/delta2vi/;
extends 'TAEB::AI::Behavior';

sub search_direction {
    my $self = shift;
    my @tiles = TAEB->grep_adjacent(sub {
        my $t = shift;
        return 0 unless $t->type eq 'wall'
                     || $t->type eq 'rock'
                     || $t->type eq 'unexplored';
        return 0 if $t->searched > 30;
        return 1;
    });
    return unless @tiles;
    return delta2vi($tiles[0]->x - TAEB->x, $tiles[0]->y - TAEB->y);
}

sub prepare {
    my $self = shift;

    my $path = TAEB::World::Path->max_match(
        sub {
            my ($tile, $path) = @_;
            $tile->searchability / (length($path) || 1);
        },
        why => "Search",
    );

    if ($path && $path->path eq '') {
        $self->currently("Searching adjacent walls and rock");
        my $stethoscope = TAEB->find_item('stethoscope');
        if ($stethoscope) {
            my $search_direction = $self->search_direction;
            if ($search_direction) {
                $self->do(apply => item      => $stethoscope,
                                   direction => $search_direction);
            }
            else {
                $self->do('search');
            }
        }
        else {
            $self->do('search');
        }
        $self->urgency('fallback');
        return;
    }

    $self->if_path($path => "Heading to a search hotspot");
}

sub urgencies {
    return {
        fallback => "searching adjacent walls and rock, or pathing to them",
    }
}

sub pickup {
    my $self = shift;
    my $item = shift;
    return $item->match(identity => 'stethoscope');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


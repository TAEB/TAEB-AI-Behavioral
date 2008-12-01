#!/usr/bin/env perl
package TAEB::AI::Behavior::Search;
use TAEB::OO;
use TAEB::Util qw/delta2vi vi2delta/;
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

    my $pmap = find_empty_panels();

    my $path = TAEB::World::Path->max_match(
        sub {
            my ($tile, $path) = @_;
            searchability($pmap, $tile) - length($path);
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

#    my ($px, $py) = $self->_panel;
#    my $panel = "$px,$py" . ($self->_panel_empty($px,$py) ? "e" : "");
#    push @bits, "p<$panel>";

sub find_empty_panels {
    my %pmap;

    for my $py (0 .. 3) {
        for my $px (0 .. 15) {
            $pmap{$px}{$py} = panel_empty(TAEB->current_level, $px, $py);
        }
    }

    return \%pmap;
}

sub panel {
    my $tile = shift;

    my $panelx = int($tile->x / 5);
    my $panely = int(($tile->y - 1) / 5);

    $panely = 3 if $panely == 4;

    return ($panelx, $panely);
}

sub panel_empty {
    my ($level, $px, $py) = @_;

    my $sx = ($px) * 5;
    my $sy = ($py) * 5 + 1;
    my $ex = ($px + 1) * 5 - 1;
    my $ey = ($py + 1) * 5;

    return 0 if ($px < 0 || $py < 0 || $px >= 20 || $py >= 4);
        # No sense searching the edge of the universe

    $ey = 21 if $ey == 20;

    for my $y ($sy .. $ey) {
        for my $x ($sx .. $ex) {
            my $tile = $level->at($x, $y);
            return 0 if !defined($tile) || $tile->type ne 'unexplored';
        }
    }

    return 1;
}

sub searchability {
    my ($pmap, $tile) = @_;
    my $searchability = 0;

    # If the square is in an 5x5 panel, and is next to a 5x5 panel which
    # is empty, it is considered much more searchable.  This should focus
    # searching efforts on parts of the map that matter.

    my (%n, $pdir);

    # Don't search in shops, there's never anything to find and it can
    # cause pathing problems past shopkeepers
    return 0 if $tile->in_shop;

    # probably a bottleneck; we shall see

    $tile->each_adjacent(sub {
        my ($adj, $dir) = @_;
        return unless $adj->type eq 'wall'
                   || $adj->type eq 'rock'
                   || $adj->type eq 'unexplored'; # just in case
        my $factor = 1;

        my ($px, $py) = panel($adj);
        my ($dx, $dy) = vi2delta($dir);

        if ($pmap->{$px + $dx}{$py + $dy}) {
            $factor = $adj->type eq 'wall' ? 1000 : 10;
        }

        $searchability += $factor * exp(- $adj->searched/5);
    });

    return $searchability;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


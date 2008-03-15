#!/usr/bin/env perl
package TAEB::AI::Behavior::Doors;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my $have_action = 0;
    my $ignore_doors = 0;

    my $locktool = TAEB->find_item('key')
                || TAEB->find_item('lock pick')
                || TAEB->find_item('credit card');

    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        return unless $tile->type eq 'closeddoor';

        if ($tile->locked eq 'locked') {
            # can we unlock? if so, try it
            if ($locktool) {
                TAEB->debug("Lock tool $locktool");
                $self->do(unlock => implement => $locktool, direction => $dir);
                $self->currently("Applying lock tool in direction " . $dir);
                $have_action = 1;
            }
            # can we kick? if so, try it
            elsif (TAEB->senses->can_kick) {
                $self->do(kick => direction => $dir);
                $self->currently("Kicking down a door");
                $have_action = 1;
            }
            # oh well
            else {
                $ignore_doors = 1;
                return;
            }
        }
        else {
            $self->do(open => direction => $dir);
            $self->currently("Trying to open a door (" . $dir . ")");
            $have_action = 1;
        }
    });
    return 0 if $ignore_doors;
    return 100 if $have_action;

    my $path = TAEB::World::Path->first_match(sub {
        shift->type eq 'closeddoor'
    });

    $self->if_path($path => "Heading towards a door");
}

sub urgencies {
    return {
        100 => "opening an adjacent door",
         50 => "path to a door",
    },
}

sub pickup {
    my $self = shift;
    my $item = shift;

    for my $unlocker ('key', 'lock pick', 'credit card') {
        # we already have this or better
        return 0 if TAEB->find_item($unlocker);

        # this is better than our best unlocker
        return 1 if $item->identity eq $unlocker;
    }

    TAEB->warning("Fell off Doors->pickup.");
    return 0;
}

make_immutable;

1;


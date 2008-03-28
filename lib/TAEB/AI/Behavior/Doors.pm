#!/usr/bin/env perl
package TAEB::AI::Behavior::Doors;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return 0 unless TAEB->senses->can_open;
    return 0 unless TAEB->current_level->has_type('closeddoor');

    my ($door, $dir);
    TAEB->any_adjacent(sub {
        my ($tile, $d) = @_;
        ($door, $dir) = ($tile, $d)
            if $tile->type eq 'closeddoor'
    });

    if ($door) {
        if ($door->locked eq 'locked') {

            # can we unlock? if so, try it
            my $locktool = TAEB->find_item('skeleton key')
                        || TAEB->find_item('lock pick')
                        || TAEB->find_item('credit card');

            if ($locktool) {
                $self->do(unlock => implement => $locktool, direction => $dir);
                $self->currently("Unlocking a door");
                return 100;
            }

            # can we kick? if so, try it
            if (TAEB->senses->can_kick) {
                $self->do(kick => direction => $dir);
                $self->currently("Kicking down a door");
                return 100;
            }

            # oh well, nothing we can do
            return 0;
        }

        # it's not locked, so open it
        $self->do(open => direction => $dir);
        $self->currently("Trying to open a door");
        return 100;
    }

    my $path = TAEB::World::Path->first_match(sub {
        shift->type eq 'closeddoor'
    }, include_endpoints => 1);

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

    for my $unlocker ('skeleton key', 'lock pick', 'credit card') {
        # we already have this or better
        return 0 if TAEB->find_item($unlocker);

        # this is better than our best unlocker
        return 1 if $item->identity eq $unlocker;
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


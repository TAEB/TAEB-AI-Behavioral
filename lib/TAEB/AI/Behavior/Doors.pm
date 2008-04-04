#!/usr/bin/env perl
package TAEB::AI::Behavior::Doors;
use TAEB::OO;
extends 'TAEB::AI::Behavior';
use List::MoreUtils 'any';

sub unlock_action {
    my $self = shift;

    if (TAEB->current_level->is_minetown) {
        return if any { $_->is_watchman } TAEB->current_level->monsters;
    }

    # can we unlock? if so, try it
    my $locktool = TAEB->find_item('Master Key of Thievery')
                || TAEB->find_item('skeleton key')
                || TAEB->find_item('lock pick')
                || TAEB->find_item('credit card');

    return (unlock =>
        implement => $locktool,
        currently => "Unlocking a door",
    ) if $locktool;

    if (TAEB->can_kick) {
        return (kick =>
            currently => "Kicking down a door",
        );
    }

    return;
}

sub prepare {
    my $self = shift;

    return 0 unless TAEB->can_open;
    return 0 unless TAEB->current_level->has_type('closeddoor');

    my ($action, %action_args) = $self->unlock_action;
    my $currently = delete $action_args{currently};

    my ($door, $dir);
    TAEB->any_adjacent(sub {
        my ($tile, $d) = @_;
        ($door, $dir) = ($tile, $d)
            if $tile->type eq 'closeddoor'
    });

    if ($door) {
        if ($door->locked eq 'locked') {
            if ($action) {
                unless ($action eq 'kick' && $door->is_shop) {
                    $self->do($action => %action_args, direction => $dir);
                    $self->currently($currently);
                    return 100;
                }
            }
        }
        else {
            # it's not locked, so open it
            $self->do(open => direction => $dir);
            $self->currently("Trying to open a door");
            return 100;
        }
    }

    my $path = TAEB::World::Path->first_match(sub {
        my $tile = shift;
        return 0 unless $tile->type eq 'closeddoor';
        return 0 if $tile->is_shop && ($action||'') eq 'kick';
        return 0 if $tile->locked eq 'locked' && !$action;
        return 1;
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
        return 1 if $item->match(identity => $unlocker);
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


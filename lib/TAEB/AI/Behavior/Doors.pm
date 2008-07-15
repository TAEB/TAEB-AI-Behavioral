#!/usr/bin/env perl
package TAEB::AI::Behavior::Doors;
use TAEB::OO;
extends 'TAEB::AI::Behavior';
use List::MoreUtils 'any';

sub unlock_action {
    my $self = shift;

    if (TAEB->current_level->is_minetown) {
        return if any { $_->is_peaceful_watchman } TAEB->current_level->monsters;
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

    my ($action, %action_args) = $self->unlock_action;
    my $currently = delete $action_args{currently};

    my @doors;
    TAEB->any_adjacent(sub {
        my ($tile, $dir) = @_;
        push @doors, [$tile, $dir]
            if $tile->type eq 'closeddoor' ||
                    ($tile->type eq 'opendoor' && $tile->blocked_door);
    });

    for (@doors) {
        my ($door, $dir) = @$_;

        if ($door->blocked_door) {
            if ($door->type eq 'opendoor' &&
                    ($door->glyph eq '-' || $door->glyph eq '|')) {
                $self->do(close => direction => $dir);
                $self->currently("Closing door");
                return 100;
            }
            elsif (TAEB->can_kick) {
                $self->do(kick => direction => $dir);
                $self->currently("Kicking down blocked door");
                return 100;
            }
        }
        elsif ($door->locked) {
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
        return 0 unless ($tile->type eq 'closeddoor' || $tile->type eq 'opendoor');
        return 0 if $tile->type eq 'opendoor' && !$tile->blocked_door;
        if ($tile->type eq 'closeddoor') {
            return 0 if $tile->is_shop && ($action||'') eq 'kick';
            return 0 if $tile->locked && !$action;
        }
        return 1;
    }, include_endpoints => 1, why => "Doors");

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


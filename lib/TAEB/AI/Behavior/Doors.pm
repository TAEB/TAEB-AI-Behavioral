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

sub door_handler {
    my $self = shift;
    my ($action, %action_args) = $self->unlock_action;
    my $currently = delete $action_args{currently};

    return sub {
        my $door = shift;

        return unless $door->isa('TAEB::World::Tile::Door');

        if ($door->blocked_door) {
            if ($door->type eq 'opendoor') {
                return sub {
                    my ($self, $door, $dir) = @_;
                    $self->do(close => direction => $dir);
                    $self->currently("Closing door");
                    return 100;
                };
            }
            elsif (TAEB->can_kick) {
                return sub {
                    my ($self, $door, $dir) = @_;
                    $self->do(kick => direction => $dir);
                    $self->currently("Kicking down blocked door");
                    return 100;
                };
            }
        }
        elsif ($door->locked) {
            if ($action) {
                unless ($action eq 'kick' && $door->is_shop) {
                    return sub {
                        my ($self, $door, $dir) = @_;
                        $self->do($action => %action_args, direction => $dir);
                        $self->currently($currently);
                        return 100;
                    };
                }
            }
        }
        elsif ($door->type eq 'closeddoor') {
            # it's not locked, so open it
            return sub {
                my ($self, $door, $dir) = @_;
                $self->do(open => direction => $dir);
                $self->currently("Trying to open a door");
                return 100;
            };
        }

        return;
    }
}

sub prepare {
    my $self = shift;

    return 0 unless TAEB->can_open;

    my $door_handler = $self->door_handler;

    my @doors;
    TAEB->any_adjacent(sub {
        my ($tile, $dir) = @_;
        push @doors, [$tile, $dir]
            if $tile->type eq 'closeddoor'
            || ($tile->type eq 'opendoor' && $tile->blocked_door);
    });

    for (@doors) {
        my ($door, $dir) = @$_;
        if (my $act_sub = $door_handler->($door)) {
            return $act_sub->($self, $door, $dir);
        }
    }

    return unless any { $door_handler->($_) }
                  TAEB->current_level->tiles_of('opendoor', 'closeddoor');

    my $path = TAEB::World::Path->first_match(sub {
        $door_handler->(shift) ? 1 : 0
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


package TAEB::AI::Behavioral::Behavior::Doors;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';
use TAEB::Util 'any';

sub unlock_action {
    my $self = shift;

    # can we unlock? if so, try it
    my $locktool = TAEB->has_item('Master Key of Thievery')
                || TAEB->has_item('skeleton key')
                || TAEB->has_item('lock pick')
                || TAEB->has_item('credit card');

    return (unlock =>
        implement => $locktool,
        currently => "Unlocking a door",
    ) if $locktool;

    if (!TAEB::Action::Kick->is_impossible) {
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

        # No check for watch, that causes oscillations
        my $minetown_check = TAEB->current_level->is_minetown
               && !$door->any_adjacent(sub { shift->type eq 'corridor' })
               && (($action_args{implement}
                 && !$action_args{implement}->match(identity => qr/key/))
                || $action eq 'kick');

        if ($door->blocked_door && !$minetown_check) {
            if ($door->type eq 'opendoor') {
                if ($door->is_empty && # can't close with stuff on them
                    !$door->level->is_rogue) { # can't close doors on roguelvl
                    return sub {
                        my ($self, $door, $dir) = @_;
                        $self->do(close => direction => $dir);
                        $self->currently("Closing door");
                        $self->urgency('unimportant');
                        return;
                    };
                }
            }
            elsif (!TAEB::Action::Kick->is_impossible) {
                return sub {
                    my ($self, $door, $dir) = @_;
                    $self->do(kick => direction => $dir);
                    $self->currently("Kicking down blocked door");
                    $self->urgency('unimportant');
                    return;
                };
            }
        }
        elsif ($door->is_locked) {
            if ($action && !$minetown_check) {
                unless ($action eq 'kick' && $door->is_shop) {
                    return sub {
                        my ($self, $door, $dir) = @_;
                        $self->do($action => %action_args, direction => $dir);
                        $self->currently($currently);
                        $self->urgency('unimportant');
                        return;
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
                $self->urgency('unimportant');
                return;
            };
        }

        return;
    }
}

sub prepare {
    my $self = shift;

    return if TAEB::Action::Open->is_impossible;

    my $door_handler = $self->door_handler;

    my @doors;
    TAEB->any_adjacent(sub {
        my ($tile, $dir) = @_;
        push @doors, [$tile, $dir]
            if ($tile->type eq 'closeddoor' && $dir =~ /[hjkl]/)
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
    }, include_endpoints => 1);

    $self->if_path($path => "Heading towards a door");
}

use constant max_urgency => 'unimportant';

sub pickup {
    my $self = shift;
    my $item = shift;

    for my $unlocker ('skeleton key', 'lock pick', 'credit card') {
        # we already have this or better
        return 0 if TAEB->has_item($unlocker);

        # this is better than our best unlocker
        return 1 if $item->match(identity => $unlocker);
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;

1;


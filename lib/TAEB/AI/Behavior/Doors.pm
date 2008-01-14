#!/usr/bin/env perl
package TAEB::AI::Behavior::Doors;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my $have_action = 0;
    my $locktool = undef; # XXX: can't use pickup any more

    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        return unless $tile->type eq 'closeddoor';

        if (TAEB->messages =~ /This door is locked\./) {
            # can we unlock? if so, try it
            if ($locktool) {
                TAEB->debug("Lock tool $locktool");
                $self->next('a' . $locktool->slot . $dir . 'y');
                $self->currently("Applying lock tool in direction " . $dir);
                $have_action = 1;
            }
            # can we kick? if so, try it
            elsif (TAEB->senses->can_kick) {
                $self->next(chr(4) . $dir);
                $self->currently("Kicking down a door");
                $have_action = 1;
            }
            # oh well
            else {
                return;
            }
        }
        else {
            $self->next('o' . $dir);
            $self->currently("Trying to open a door (" . $dir . ")");
            $have_action = 1;
        }
    });
    return 100 if $have_action;

    $self->currently("Heading towards a door");
    my $path = TAEB::World::Path->first_match(sub {
        shift->type eq 'closeddoor'
    });
    $self->path($path);

    return $path && length($path->path) ? 50 : 0;
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
        return 0 if TAEB->inventory->find($unlocker);

        # this is better than our best unlocker
        return 1 if $item->identity eq $unlocker;
    }

    TAEB->warning("Fell off Doors->pickup.");
    return 0;
}
1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Doors;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my $have_action = 0;
    my $locktool = TAEB->inventory->find($self->can('pickup'));

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
    for my $unlocker (qr/key/, qr/lock pick/, qr/credit card/) {
        if ($_ =~ $unlocker && !TAEB->inventory->find($unlocker)) {
            return 1;
        }
    }
    return 0;
}
1;


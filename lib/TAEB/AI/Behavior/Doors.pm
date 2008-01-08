#!/usr/bin/env perl
package TAEB::AI::Behavior::Doors;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return 0 unless TAEB->senses->can_kick;

    my $found_door;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        if ($tile->type eq 'closeddoor') {
            $self->next(chr(4) . $dir);
            $self->currently("Kicking down a door");
            $found_door = 1;
        }
    });
    return 100 if $found_door;

    $self->currently("Heading towards a door");
    my $path = TAEB::World::Path->first_match(sub { shift->type eq 'closeddoor' });
    $self->path($path);

    return $path && length($path->path) ? 50 : 0;
}

sub urgencies {
    return {
        100 => "kicking down an adjacent door",
         50 => "path to a door",
    },
}

sub pickup {
    for my $unlocker('key', 'lock pick', 'credit card') {
        if ($_ =~ $unlocker && !TAEB->inventory->find(qr/$unlocker/)) {
            return 1;
        }
    }
}
1;


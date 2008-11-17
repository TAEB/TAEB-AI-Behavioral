#!/usr/bin/env perl
package TAEB::AI::Behavior::Search;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my $path = TAEB::World::Path->max_match(
        sub {
            my ($tile, $path) = @_;
            $tile->searchability / (length($path) || 1);
        },
        why => "Search",
    );

    if ($path && $path->path eq '') {
        $self->currently("Searching adjacent walls and rock");
        $self->do('search');
        return URG_FALLBACK;
    }

    $self->if_path($path => "Heading to a search hotspot");
}

sub urgencies {
    return {
        URG_FALLBACK, "searching adjacent walls and rock, or pathing to them",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


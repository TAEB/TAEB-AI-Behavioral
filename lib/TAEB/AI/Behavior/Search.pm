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
        return 100;
    }

    $self->if_path($path => "Heading to a search hotspot");
}

sub urgencies {
    return {
        100 => "searching adjacent walls and rock",
         50 => "path to an unsearched wall",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


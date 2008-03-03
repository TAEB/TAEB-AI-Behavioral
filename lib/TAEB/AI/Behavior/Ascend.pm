#!/usr/bin/env perl
package TAEB::AI::Behavior::Ascend;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # we don't actually want TAEB escaping just yet
    return 0 if TAEB->z == 1;

    # are we on <? if so, head up
    if (TAEB->current_tile->floor_glyph eq '<') {
        $self->currently("Ascending");
        $self->next('<');
        return 100;
    }

    # find our <
    my $path = TAEB::World::Path->first_match(
        sub { shift->floor_glyph eq '<' },
    );

    $self->if_path($path => "Heading towards the upstairs");
}

sub urgencies {
    return {
        100 => "ascending stairs",
         50 => "path to upstairs",
    };
}

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Descend;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # are we on >? if so, head down
    if (TAEB->current_tile->floor_glyph eq '>') {
        $self->currently("Descending");
        $self->next('>');
        return 100;
    }

    # find our >
    my $path = TAEB::World::Path->first_match(
        sub { shift->floor_glyph eq '>' },
    );

    $self->currently("Heading towards the downstairs");
    $self->path($path);
    return $path ? 50 : 0;
}

sub urgencies {
    return {
        100 => "descending",
         50 => "path to downstairs",
    };
}

1;


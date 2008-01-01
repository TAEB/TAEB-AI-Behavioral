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

    # poor optimization: do we have a > on screen? (XXX: what if it's obscured?)
    return 0 unless TAEB->map_like(qr/>/);

    # find our >
    my $path = TAEB::World::Path->first_match(
        sub { shift->floor_glyph eq '>' },
    );

    $self->currently("Heading towards the downstairs");
    $self->path($path);
    return $path ? 50 : 0;
}

sub weights {
    return {
        100 => "descending",
         50 => "path to downstairs",
    };
}

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::Descend;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # are we on >? if so, head down
    if (TAEB->current_tile->floor_glyph eq '>') {
        return 99;
    }

    # poor optimization: do we have a > on screen? (XXX: what if it's obscured?)
    return 0 unless TAEB->map_like(qr/>/);

    # find our >
    my $path = TAEB::World::Path->first_match(
        sub { shift->floor_glyph eq '>' },
    );

    $self->path($path);

    return $path ? 50 : 0;
}

sub next_action {
    my $self = shift;

    # descend if able
    return '>' if TAEB->current_tile->floor_glyph eq '>';

    # otherwise, head towards >
    substr($self->path->path, 0, 1);
}

sub currently { "Descending." }

sub max_urgency { 99 }

1;


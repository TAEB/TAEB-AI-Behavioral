#!/usr/bin/env perl
package TAEB::AI::Behavior::IdentifyRing;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return 0 if TAEB->is_blind;

    my @items = grep { $self->pickup($_) } TAEB->inventory->items;
    return 0 unless @items;

    my $ring = shift @items;

    my $level = TAEB->nearest_level(sub { shift->has_type('sink') })
        or return 0;

    # are we standing on a sink? if so, drop!
    if (TAEB->current_tile->type eq 'sink') {
        $self->currently("Dropping the ring in the sink");
        $self->do(drop => item => $ring);
        return 100;
    }

    # find a sink
    my $path = TAEB::World::Path->first_match(
        sub { shift->type eq 'sink' },
        on_level => $level,
    );

    $self->if_path($path => "Heading towards a sink");
}

sub pickup {
    my $self = shift;
    my $item = shift;

    # we only care about unidentified stuff
    return 0 if $item->identity;

    # collect unknown rings.
    if ($item->class eq 'ring') {
        return 1;
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::AI::Behavior::IdentifyRing;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) } TAEB->inventory->items;
    return 0 unless @items;
    return 0 if TAEB->is_blind;

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

sub drop {
    my $self = shift;
    my $item = shift;

    return if TAEB->current_tile->type ne 'sink'
           || TAEB->is_blind
           || $item->identity;


    TAEB->debug("Yes, I want to drop $item because I want to find out what it is.");
    return 1;
}

sub urgencies {
    return {
        100 => "sink-identifying a ring",
        50 => "path to sink",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


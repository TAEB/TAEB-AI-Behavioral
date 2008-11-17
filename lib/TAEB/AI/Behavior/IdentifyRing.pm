#!/usr/bin/env perl
package TAEB::AI::Behavior::IdentifyRing;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return URG_NONE if TAEB->is_blind;

    my @items = grep { $self->pickup($_) } TAEB->inventory->items;
    return URG_NONE unless @items;

    my $level = TAEB->nearest_level(sub { shift->has_type('sink') })
        or return URG_NONE;

    # are we standing on a sink? if so, drop!
    if (TAEB->current_tile->type eq 'sink') {
        $self->currently("Dropping the ring in the sink");
        $self->do(drop => items => \@items);
        return URG_UNIMPORTANT;
    }

    # find a sink
    my $path = TAEB::World::Path->first_match(
        sub { shift->type eq 'sink' },
        on_level => $level,
        why => "IdentifyRing",
    );

    $self->if_path($path => "Heading towards a sink");
}

# collect unknown rings
sub pickup {
    my $self = shift;
    my $item = shift;

    # we only care about unidentified stuff and rings
    return 0 unless $item->match(identity => undef, class => 'ring');

    return 1;
}

sub drop {
    my $self = shift;
    my $item = shift;

    return unless $item->match(class => 'ring', identity => undef);

    return if TAEB->current_tile->type ne 'sink'
           || TAEB->is_blind;

    TAEB->debug("Yes, I want to drop $item because I want to find out what it is.");
    return 1;
}

sub urgencies {
    return {
        URG_UNIMPORTANT, "sink-identifying a ring",
        URG_FALLBACK,    "path to sink",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


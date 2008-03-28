#!/usr/bin/env perl
package TAEB::AI::Behavior::CurseCheck;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # Can't see altar flash when blind
    return 0 if TAEB->senses->is_blind;
    return 0 unless TAEB->current_level->has_type('altar');

    my @drop = grep { $_->buc eq 'unknown' && $_->appearance ne 'gold piece' } TAEB->inventory->items;

    # No point in cursechecking no items
    return 0 unless @drop;

    if (TAEB->current_tile->type eq 'altar') {
        $self->currently("Dropping items for cursechecking.");
        $self->do(drop => items => \@drop);
        return 100;
    }

    # find an altar to cursecheck on
    my $path = TAEB::World::Path->first_match(
        sub { shift->type eq 'altar' },
    );

    $self->if_path($path => "Heading towards an altar");
}

sub drop {
    my $self = shift;
    my $item = shift;

    return if TAEB->current_tile->type ne 'altar'
           || TAEB->senses->is_blind
           || $item->buc ne 'unknown';

    TAEB->debug("Yes, I want to drop $item because it needs to be cursechecked.");
    return 1;
}

sub urgencies {
    return {
        100 => "cursechecking at an altar",
         50 => "locating altar",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


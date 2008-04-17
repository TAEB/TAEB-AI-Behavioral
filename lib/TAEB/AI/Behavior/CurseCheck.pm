#!/usr/bin/env perl
package TAEB::AI::Behavior::CurseCheck;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # Can't see altar flash when blind
    return 0 if TAEB->is_blind;

    my $level = TAEB->nearest_level(sub { shift->has_type('altar') })
        or return 0;

    my @drop = grep { $_->can_drop &&
                      $_->match(buc => undef)
                    } TAEB->inventory->items;

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
        on_level => $level,
    );

    $self->if_path($path => "Heading towards an altar");
}

sub drop {
    my $self = shift;
    my $item = shift;

    return if TAEB->current_tile->type ne 'altar'
           || TAEB->is_blind
           || !$item->can_drop
           || $item->match(not_buc => undef)
           || $item->match(appearance => 'gold piece');

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


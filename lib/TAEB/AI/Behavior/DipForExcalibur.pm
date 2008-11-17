#!/usr/bin/env perl
package TAEB::AI::Behavior::DipForExcalibur;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub can_make_excalibur {
    return unless TAEB->align eq 'Law';

    # only one Excalibur. Alas.
    return if TAEB->knowledge->artifacts->was_seen("Excalibur");

    return 1;
}

sub prepare {
    my $self = shift;

    return URG_NONE unless $self->can_make_excalibur;

    # are we eligible to dip for Excalibur now?
    return URG_NONE unless TAEB->level >= 5;

    my $longsword = TAEB->find_item("long sword")
        or return URG_NONE;

    my $level = TAEB->nearest_level(sub {
        my $lvl = shift;
        return 0 if $lvl->is_minetown;
        return $lvl->has_type('fountain');
    });

    return URG_NONE if !$level;

    unless (TAEB->current_level->is_minetown) {
        # are we standing on a fountain? if so, dip!
        if (TAEB->current_tile->type eq 'fountain') {
            $self->currently("Dipping for Excalibur!");
            $self->do(dip => item => $longsword, into => "fountain");
            return URG_UNIMPORTANT;
        }
    }

    # find a fountain
    my $path = TAEB::World::Path->first_match(
        sub { shift->type eq 'fountain' },
        on_level => $level,
        why => "DipForExcalibur",
    );

    $self->if_path($path => "Heading towards a fountain");
}

sub urgencies {
    return {
        URG_UNIMPORTANT, "dipping for Excalibur",
        URG_FALLBACK,    "path to fountain",
    };
}

sub pickup {
    my $self = shift;
    my $item = shift;

    if ($item->match(identity => 'long sword')) {
        return unless $self->can_make_excalibur;
        return if TAEB->find_item("long sword");
        return 1;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


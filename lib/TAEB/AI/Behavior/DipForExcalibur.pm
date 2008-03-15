#!/usr/bin/env perl
package TAEB::AI::Behavior::DipForExcalibur;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # are we eligible to dip for Excalibur?
    return 0 unless TAEB->level >= 5;
    return 0 unless TAEB->align eq 'Law';

    # only one Excalibur. Alas.
    return 0 if TAEB::Spoilers::Item::Artifact->seen("Excalibur");

    # do we have a long sword to dip in our inventory?
    my $longsword = TAEB->find_item("long sword")
        or return 0;

    # are we standing on a fountain? if so, dip!
    if (TAEB->current_tile->type eq 'fountain') {
        $self->currently("Dipping for Excalibur!");
        $self->do(dip => item => $longsword, into => "fountain");
        return 100;
    }

    # find a fountain
    my $path = TAEB::World::Path->first_match(
        sub { shift->type eq 'fountain' },
    );

    $self->if_path($path => "Heading towards a fountain");
}

sub urgencies {
    return {
        100 => "dipping for Excalibur",
         50 => "path to fountain",
    };
}

make_immutable;

1;


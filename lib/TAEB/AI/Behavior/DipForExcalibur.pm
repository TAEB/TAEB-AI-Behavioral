#!/usr/bin/env perl
package TAEB::AI::Behavior::DipForExcalibur;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # are we eligible to dip for Excalibur?
    return 0 unless TAEB->level >= 5;
    return 0 unless TAEB->align eq 'Law';

    # only one Excalibur. Alas.
    return 0 if TAEB::Knowledge::Item::Artifact->seen("Excalibur");

    # do we have a long sword to dip in our inventory?
    my $longsword = TAEB->inventory->find_item(sub {/long sword/})
        or return 0;

    # are we standing on a fountain? if so, dip!
    if (TAEB->current_tile->type eq 'fountain') {
        $self->currently("Dipping for Excalibur!");
        $self->next("#dip\n" . $longsword->slot . "y");
        return 100;
    }

    # find a fountain
    my $path = TAEB::World::Path->first_match(
        sub { shift->type eq 'fountain' },
    );

    $self->currently("Heading towards a fountain");
    $self->path($path);
    return $path ? 50 : 0;
}

sub urgencies {
    return {
        100 => "dipping for Excalibur",
         50 => "path to fountain",
    };
}

1;


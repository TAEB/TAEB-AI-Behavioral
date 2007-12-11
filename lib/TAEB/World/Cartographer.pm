#!/usr/bin/env perl
package TAEB::World::Cartographer;
use Moose;

has dungeon => (
    is       => 'rw',
    isa      => 'TAEB::World::Dungeon',
    weak_ref => 1,
    required => 1,
);

has x => (
    is => 'rw',
    isa => 'Int',
);

has y => (
    is => 'rw',
    isa => 'Int',
);

sub update {
    my $self  = shift;
    my $taeb  = shift;
    my $level = $self->dungeon->current_level;

    for my $y (1 .. 21) {
        for my $x (0 .. 79) {
            if ($taeb->vt->at($x, $y) ne $level->at($x, $y)->glyph) {
                $level->update_tile($x, $y, $taeb->vt->at($x, $y));
            }
        }
    }

    # XXX: ugh. this needs to be smarter.
    $self->x($taeb->vt->x);
    $self->y($taeb->vt->y);
}

1;


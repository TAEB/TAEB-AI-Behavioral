#!/usr/bin/env perl
package TAEB::World::Cartographer;
use Moose;

has dungeon => (
    is       => 'rw',
    isa      => 'TAEB::World::Dungeon',
    weak_ref => 1,
    required => 1,
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
}

1;


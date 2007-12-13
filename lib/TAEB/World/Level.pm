#!/usr/bin/env perl
package TAEB::World::Level;
use Moose;

has tiles => (
    is      => 'rw',
    isa     => 'ArrayRef[ArrayRef[TAEB::World::Tile]]',
    default => sub {
        my $self = shift;
        # ugly, but ok
        [ map { my $y = $_;
            [ map {
                TAEB::World::Tile->new(level => $self, x => $_, y => $y)
            } 0 .. 79 ]
        } 0 .. 23 ]
    },
);

has branch => (
    is       => 'rw',
    isa      => 'TAEB::World::Branch',
    weak_ref => 1,
);

has z => (
    is  => 'rw',
    isa => 'Int',
);

sub at {
    my $self = shift;
    my $x = shift;
    my $y = shift;

    return $self->tiles->[$y][$x];
}

sub update_tile {
    my $self     = shift;
    my $x        = shift;
    my $y        = shift;
    my $newglyph = shift;

    # replace with stairs if applicable
    if (($newglyph eq '<' || $newglyph eq '>') && $self->tiles->[$y][$x]->type ne 'stairs') {
        $self->tiles->[$y][$x] = TAEB::World::Tile::Stairs->new_from($self->tiles->[$y][$x]);
    }

    $self->tiles->[$y][$x]->update($newglyph);
}

sub step_on {
    my $self = shift;
    my $x = shift;
    my $y = shift;

    $self->tiles->[$y][$x]->step_on;
}

1;


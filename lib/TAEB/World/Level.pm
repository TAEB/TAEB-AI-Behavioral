#!/usr/bin/env perl
package TAEB::World::Level;
use Moose;
use TAEB::Util qw/deltas direction/;

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
    my $x = @_ ? shift : TAEB->x;
    my $y = @_ ? shift : TAEB->y;

    return $self->tiles->[$y][$x];
}

sub update_tile {
    my $self     = shift;
    my $x        = shift;
    my $y        = shift;
    my $newglyph = shift;
    my $color    = shift;

    # replace with stairs if applicable
    if (($newglyph eq '<' || $newglyph eq '>') && $self->tiles->[$y][$x]->type ne 'stairs') {
        $self->tiles->[$y][$x] = TAEB::World::Tile::Stairs->new_from($self->tiles->[$y][$x]);
    }

    $self->tiles->[$y][$x]->update($newglyph, $color);
}

sub step_on {
    my $self = shift;
    my $x = shift;
    my $y = shift;

    $self->tiles->[$y][$x]->step_on;
}

=head2 radiate CODE[, ARGS] -> (Str | (Str, Int))

This method will radiate in the eight NetHack directions. It will call the
coderef for each tile encountered. The coderef will receive the tile as its
argument. Once the coderef returns a true value, then the radiating stops and
something will be returned:

If called in scalar context, the vi-key direction will be returned. If called
in list context, the vi-key direction and distance will be returned.

The optional arguments are:

=over 4

=item max (default: 80)

How far to radiate outwards. You probably can't throw a dagger all the way
across the level, so you may want to decrease it to something more realistic.
Like 3, har har. You're weak.

=back

=cut

sub radiate {
    my $self = shift;
    my $code = shift;
    my %args = (
        max => 80, # hey, we may want to throw all the way across the level..
        @_,
    );

    # check each direction
    DIRECTION: for (deltas) {
        my ($dx, $dy) = @$_;
        my ($x, $y) = (TAEB->x, TAEB->y);

        for (1 .. $args{max}) {
            $x += $dx; $y += $dy;

            # have we fallen off the map? if so, stop this line of radiation
            my $tile = TAEB->current_level->at($x, $y) or next DIRECTION;

            my $ret = $code->($tile);
            if ($ret) {
                # if they ask for a scalar, give them the direction
                return direction($x, $y) if !wantarray;

                # if they ask for a list, give them (direction, distance)
                return (direction($x, $y), $_);
            }

            # stop radiating
            $tile->is_walkable or next DIRECTION;

        }
    }

}

1;


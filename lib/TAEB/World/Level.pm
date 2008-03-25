#!/usr/bin/env perl
package TAEB::World::Level;
use TAEB::OO;
use TAEB::Util qw/deltas delta2vi vi2delta/;

use overload
    q{""} => sub {
        my $self = shift;
        sprintf "[%s: branch=%s, dlvl=%d, exits=%d]",
            $self->meta->name,
            $self->branch,
            $self->z,
            scalar @{ $self->exits };
    };

has tiles => (
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
    isa      => 'TAEB::World::Branch',
    weak_ref => 1,
);

has z => (
    isa => 'Int',
);

has monsters => (
    isa     => 'HashRef[TAEB::World::Monster]',
);

has turns_spent_on => (
    isa     => 'Int',
    default => 0,
);

has pickaxe => (
    isa     => 'Int',
    default => 0,
);

has exits => (
    isa        => 'ArrayRef[TAEB::World::Tile]',
    default    => sub { [] },
    auto_deref => 1,
);

sub at {
    my $self = shift;
    my $x = @_ ? shift : TAEB->x;
    my $y = @_ ? shift : TAEB->y;

    return if $x < 0 || $y < 0;

    return $self->tiles->[$y][$x];
}

sub at_direction {
    my $self      = shift;
    my $x         = @_ > 2 ? shift : TAEB->x;
    my $y         = @_ > 1 ? shift : TAEB->y;
    my $direction = shift;

    my ($dx, $dy) = vi2delta($direction);

    $self->at($x + $dx, $y + $dy);
}

sub update_tile {
    my $self     = shift;
    my $x        = shift;
    my $y        = shift;
    my $newglyph = shift;
    my $color    = shift;

    $self->tiles->[$y][$x]->update($newglyph, $color);
}

sub step_on {
    my $self = shift;
    my $x = shift;
    my $y = shift;

    $self->turns_spent_on($self->turns_spent_on + 1);
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
                return delta2vi($dx, $dy) if !wantarray;

                # if they ask for a list, give them (direction, distance)
                return (delta2vi($dx, $dy), $_);
            }

            # stop radiating
            $tile->is_walkable or next DIRECTION;

        }
    }

}

sub find_exit {
    my $self = shift;
    my $tile = shift;

    for (my $i = 0; $i < @{ $self->exits }; ++$i) {
        return $i if $self->exits->[$i] == $tile;
    }

    return undef;
}

sub add_exit {
    my $self = shift;
    my $tile = shift;

    push @{ $self->exits }, $tile unless defined $self->find_exit($tile);
}

sub remove_exit {
    my $self = shift;
    my $tile = shift;
    defined(my $i = $self->find_exit($tile)) or return;

    splice @{ $self->exits }, $i, 1;
}

sub exits_of_type {
    my $self = shift;
    my $type = shift;
    my @tiles = grep { $_->type eq $type } $self->exits;

    return @tiles if wantarray;
    return $tiles[0];
}

sub stairs_down { shift->exits_of_type('stairsdown') }
sub stairs_up { shift->exits_of_type('stairsup') }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


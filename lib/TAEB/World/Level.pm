#!/usr/bin/env perl
package TAEB::World::Level;
use TAEB::OO;
use TAEB::Util qw/deltas delta2vi vi2delta tile_types/;
use Scalar::Util 'refaddr';

use overload
    q{""} => sub {
        my $self = shift;
        sprintf "[%s: branch=%s, dlvl=%d]",
            $self->meta->name,
            $self->branch,
            $self->z;
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
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef[TAEB::World::Monster]',
    auto_deref => 1,
    default    => sub { [] },
    provides   => {
        push   => 'add_monster',
        clear  => 'clear_monsters',
        empty  => 'has_monsters',
        count  => 'monster_count',
    }
);

has turns_spent_on => (
    isa     => 'Int',
    default => 0,
);

has pickaxe => (
    isa     => 'Int',
    default => 0,
);

has tiles_by_type => (
    isa     => 'HashRef[ArrayRef[TAEB::World::Tile]]',
    default => sub {
        +{ map { $_ => [] } tile_types }
    },
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
            $tile->is_walkable(1) or next DIRECTION;

        }
    }

}

sub remove_monster {
    my $self    = shift;
    my $monster = shift;

    for (my $i = 0; $i < $self->monster_count; ++$i) {
        if (refaddr($self->monsters->[$i]) == refaddr($monster)) {
            splice @{ $self->monsters }, $i, 1;
            return 1;
        }
    }

    TAEB->warning("Unable to remove $monster from the current level!");
}

my @unregisterable = qw(rock wall floor corridor obscured);
my %is_unregisterable = map { $_ => 1 } @unregisterable;
sub is_unregisterable { $is_unregisterable{$_[1]} }

sub register_tile {
    my $self = shift;
    my $tile = shift;
    my $type = $tile->type;

    push @{ $self->tiles_by_type->{$type} }, $tile
        unless $self->is_unregisterable($type);
}

sub unregister_tile {
    my $self = shift;
    my $tile = shift;
    my $type = $tile->type;

    return if $self->is_unregisterable($type);

    for (my $i = 0; $i < @{ $self->tiles_by_type->{$type} }; ++$i) {
        if (refaddr($self->tiles_by_type->{$type}->[$i]) == refaddr($tile)) {
            splice @{ $self->tiles_by_type->{$type} }, $i, 1;
            return 1;
        }
    }

    TAEB->warning("Unable to unregister $tile");
}

sub has_type {
    my $self = shift;
    my $type = shift;

    return @{ $self->tiles_by_type->{$type} }
}

sub has_enemies { grep { $_->is_enemy } shift->monsters }

sub exits {
    my $self = shift;
    return map { @{ $self->tiles_by_type->{$_} } } qw/stairsup stairsdown/;
}

sub exit_towards {
    my $self = shift;
    my $other = shift;

    if ($self->branch eq $other->branch) {
        return $self->has_type('stairsdown') if $self->z > $other->z;
        return $self->has_type('stairsup');
    }

    die "I don't know how to do $self->exit_towards($other) when the levels are in different branches.";
}

sub adjacent_levels { grep { defined } map { $_->other_side } shift->exits }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


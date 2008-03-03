#!/usr/bin/env perl
package TAEB::World::Dungeon;
use Moose;
use TAEB::Util 'delta2vi';

has branches => (
    is      => 'rw',
    isa     => 'HashRef[TAEB::World::Branch]',
    default => sub {
        my $self = shift;

        my @names = qw/dungeons gehennom mines quest
                       sokoban ludios vlad planes/;
        return {
            map { $_ => TAEB::World::Branch->new(name => $_, dungeon => $self) }
                @names
          }
    },
);

has current_level => (
    is => 'rw',
    isa => 'TAEB::World::Level',
    handles => [qw/z/],
);

has cartographer => (
    is      => 'rw',
    isa     => 'TAEB::World::Cartographer',
    default => sub {
        my $self = shift;
        TAEB::World::Cartographer->new(dungeon => $self)
    },
    handles => [qw/update x y map_like/],
);

# we start off in dungeon 1. this helps keeps things tidy (we only have to
# worry about level generation on level change)
sub BUILD {
    my $self = shift;
    my $dungeons = $self->branches->{dungeons};
    my $level = TAEB::World::Level->new(branch => $dungeons, z => 1);
    $dungeons->levels([$level]);
    $self->current_level($level);
}

=head2 current_tile -> Tile

The tile TAEB is currently standing on.

=cut

sub current_tile {
    my $self = shift;
    $self->current_level->at;
}

=head2 each_adjacent Code[, Tile]

Runs the coderef for each tile adjacent to the given tile (or the current
tile). The coderef will receive two arguments: the tile object and the vi key
corresponding to the direction.

=cut

sub each_adjacent {
    my $self = shift;
    my $code = shift;
    my $tile = shift || $self->current_tile;

    my $level = $tile->level;
    my $x     = $tile->x;
    my $y     = $tile->y;

    for my $dy (-1 .. 1) {
        for my $dx (-1 .. 1) {
            next unless $dy || $dx; # skip 0, 0
            my $dir = delta2vi($dx, $dy);

            my $tile = $level->at(
                $dx + $x,
                $dy + $y,
            );

            $code->($tile, $dir);
        }
    }
}

=head2 each_orthogonal Code[, Tile]

Runs the coderef for each tile adjacent to the given tile (or the current
tile) in one of the cardinal directions (no diagonals). The coderef will
receive two arguments: the tile object and the vi key corresponding to the
direction.

=cut

sub each_orthogonal {
    my $self = shift;
    my $code = shift;
    my $tile = shift || $self->current_tile;

    my $level = $tile->level;
    my $x     = $tile->x;
    my $y     = $tile->y;

    for my $dy (-1 .. 1) {
        for my $dx (-1 .. 1) {
            next unless $dy || $dx; # skip 0, 0
            next if     $dy && $dx; # skip diagonals
            my $dir = delta2vi($dx, $dy);

            my $tile = $level->at(
                $dx + $x,
                $dy + $y,
            );

            $code->($tile, $dir);
        }
    }
}

make_immutable;

1;


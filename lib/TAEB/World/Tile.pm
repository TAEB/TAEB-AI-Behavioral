#!/usr/bin/env perl
package TAEB::World::Tile;
use Moose;
use Moose::Util::TypeConstraints 'enum';
use TAEB::Util qw/tile_types glyph_to_type/;

has level => (
    is       => 'rw',
    isa      => 'TAEB::World::Level',
    weak_ref => 1,
    required => 1,
);

has room => (
    is       => 'rw',
    isa      => 'TAEB::World::Room',
    weak_ref => 1,
);

enum TileType => tile_types;

has type => (
    is      => 'rw',
    isa     => 'TileType',
    default => 'obscured',
);

has glyph => (
    is      => 'rw',
    isa     => 'Str',
    default => "\0",
);

has floor_glyph => (
    is      => 'rw',
    isa     => 'Str',
    default => "\0",
);

has stepped_on => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has x => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has y => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has searched => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

sub update {
    my $self = shift;
    my $newglyph = shift;

    $self->glyph($newglyph);

    # dark rooms
    return if $self->glyph eq "\0" && $self->floor_glyph eq '.';

    # if glyph_to_type returns false, it's not a dungeon feature, it's an item
    # or monster. we don't want to update the floor_glyph or tile type.
    my $type = glyph_to_type($newglyph) or return;

    if (ref($type) eq 'ARRAY') {
        # XXX: use ; to figure out which we're dealing with
        $type = $type->[0];
    }

    $self->type($type);
    $self->floor_glyph($newglyph);
}

sub has_monster {
    my $self = shift;

    # rationale: TAEB is no monster, he's just misunderstood
    return 0 if $self->x == $main::taeb->x
             && $self->y == $main::taeb->y;

    $self->glyph =~ /[a-zA-Z@~&';:]/;
}

sub is_walkable {
    my $self = shift;

    # XXX: yes. I know. shut up.
    return 0 if $self->glyph eq "0";

    # this is obscured and ISN'T solid rock, so it's probably walkable
    # XXX: fish
    return 1 if $self->type eq 'obscured' && $self->glyph ne "\0";

    $self->floor_glyph =~ /[.,<>^\\_{#]/;
}

sub step_on {
    my $self = shift;

    $self->stepped_on($self->stepped_on + 1);
}

sub each_neighbor {
    my $self = shift;
    my $code = shift;

    my ($x, $y) = ($self->y, $self->x);

    for my $dy (-1 .. 1) {
        for my $dx (-1 .. 1) {
            # NOT skipping 0, 0
            my $tile = $self->level->at($x + $dx, $y + $dy)
                or next;
            $code->($tile);
        }
    }
}

1;


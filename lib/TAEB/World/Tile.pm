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

#has room => (
#    is       => 'rw',
#    isa      => 'TAEB::World::Room',
#    weak_ref => 1,
#);

enum TileType => tile_types;

has type => (
    is      => 'rw',
    isa     => 'TileType',
    default => 'rock',
);

has glyph => (
    is      => 'rw',
    isa     => 'Str',
    default => ' ',
);

has floor_glyph => (
    is      => 'rw',
    isa     => 'Str',
    default => ' ',
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

has explored => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

sub update {
    my $self = shift;
    my $newglyph = shift;

    $self->glyph($newglyph);

    # dark rooms
    return if $self->glyph eq ' ' && $self->floor_glyph eq '.';

    # if glyph_to_type returns false, it's not a dungeon feature, it's an item
    # or monster. we don't want to update the floor_glyph or tile type.
    my $type = glyph_to_type($newglyph);

    if (ref($type) eq 'ARRAY') {
        # XXX: use ; to figure out which we're dealing with
        $type = $type->[0];
    }

    # if we unveil a square and it was previously rock, then it's obscured
    # if it was anything else, then it became obscured, and we don't want to
    # change what we know about it
    if ($type eq 'obscured') {
        $self->type('obscured') if $self->type eq 'rock';
        return;
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
    return 0 if $self->glyph eq '0';

    # obscured is probably walkable
    # XXX: fish
    return 1 if $self->type eq 'obscured';

    $self->floor_glyph =~ /[.,<>^\\_{#]/;
}

sub step_on {
    my $self = shift;

    $self->stepped_on($self->stepped_on + 1);
    $self->explored(1);
}

sub each_neighbor {
    my $self = shift;
    my $code = shift;

    my ($x, $y) = ($self->x, $self->y);

    for my $dy (-1 .. 1) {
        for my $dx (-1 .. 1) {
            # NOT skipping 0, 0
            my $tile = $self->level->at($x + $dx, $y + $dy)
                or next;
            $code->($tile);
        }
    }
}

sub each_other_neighbor {
    my $self = shift;
    my $code = shift;

    my ($x, $y) = ($self->x, $self->y);

    for my $dy (-1 .. 1) {
        for my $dx (-1 .. 1) {
            next unless $dy || $dx;

            my $tile = $self->level->at($x + $dx, $y + $dy)
                or next;
            $code->($tile);
        }
    }
}

sub debug_draw_explored {
    my $self = shift;
    ($self->explored ? "\e[1;33m" : '') . $self->glyph
}

sub debug_draw_stepped {
    my $self = shift;
    ($self->stepped_on ? "\e[1;35m" : '') . $self->glyph
}

sub debug_draw_walkable {
    my $self = shift;
    ($self->is_walkable ? "\e[1;32m" : '') . $self->glyph
}

sub debug_draw_floor {
    shift->floor_glyph
}

sub debug_draw_glyph {
    shift->glyph
}

sub debug_draw_obscured {
    my $self = shift;
    $self->type eq 'obscured' ? '?' : $self->glyph
}

sub debug_draw_rock {
    my $self = shift;
    $self->type eq 'rock' ? '*' : $self->glyph
}

1;


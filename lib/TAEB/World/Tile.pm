#!/usr/bin/env perl
package TAEB::World::Tile;
use Moose;
use TAEB::Util qw/glyph_to_type delta2vi/;

has level => (
    is       => 'rw',
    isa      => 'TAEB::World::Level',
    weak_ref => 1,
    required => 1,
    handles  => [qw/z/],
);

#has room => (
#    is       => 'rw',
#    isa      => 'TAEB::World::Room',
#    weak_ref => 1,
#);


has type => (
    is      => 'rw',
    isa     => 'TileType',
    default => 'rock',
    trigger => sub {
        my $self = shift;
        $self->rebless(@_);
    },
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

has elbereths => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has interesting => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has monster => (
    is       => 'rw',
    isa      => 'TAEB::World::Monster',
    weak_ref => 1,
);

has items => (
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef[TAEB::World::Item]',
    default    => sub { [] },
    auto_deref => 1,
    provides   => {
        push => 'add_item',
    },
);

=head2 basic_cost -> Int

This returns the basic cost of entering a tile. It's not very smart, but it
should do the trick for avoiding known traps and preferring the trodden path.

=cut

sub basic_cost {
    my $self = shift;
    my $cost = 100;

    $cost = 1000 if $self->type eq 'trap';

    $cost = $cost * .9 if $self->stepped_on;

    return int($cost);
}

sub update {
    my $self     = shift;
    my $newglyph = shift;
    my $color    = shift;
    my $oldglyph = $self->glyph;
    my $oldtype  = $self->type;

    # gas spore explosions should not update the map
    return if $newglyph =~ m{^[\\/-]$} && $color == 1;

    $self->glyph($newglyph);

    # dark rooms
    return if $self->glyph eq ' ' && $self->floor_glyph eq '.';

    my $newtype = glyph_to_type($newglyph, $color);

    # if we unveil a square and it was previously rock, then it's obscured
    # perhaps we entered a room and a tile changed from ' ' to '!'
    # if the tile's type was anything else, then it *became* obscured, and we
    # don't want to change what we know about it
    # XXX: if the type is olddoor then we probably kicked/opened the door and
    # something walked onto it. this needs improvement
    if ($newtype eq 'obscured') {
        # ghosts and xorns should not update the map
        return if $newglyph eq 'X';

        $self->type('obscured') if $oldtype eq 'rock' || $oldtype eq 'closeddoor';
        return;
    }

    # so this is definitely a dungeon feature, since glyph_to_type returned
    # something other than 'obscured'
    $self->type($newtype);
    $self->floor_glyph($newglyph);
}

# automatically upgrade the tile if upgrading would make it more specific
# (e.g. TAEB::World::Tile -> TAEB::World::Tile::Stairs)
# we also downgrade (and possibly upgrade) tiles if they change type
# since this is run whenever we change type, this should keep the tile's
# class completely up to date
sub rebless {
    my $self    = shift;
    my $newtype = shift;

    my $new_pkg = "TAEB::World::Tile::\L\u$newtype";

    # if the new_pkg doesn't exist, then just go with the regular Tile
    return $self->downgrade unless eval { $new_pkg->meta };

    # no work to be done, yay
    return if blessed($self) eq $new_pkg;

    # are we a superclass of the new package? if not, we need to revert
    # to a regular Tile so we can be reblessed into a subclass of Tile
    # in other words, Moose doesn't let you rebless into a sibling class
    unless (eval { $new_pkg->isa(blessed($self)) }) {
        $self->downgrade("Reblessing a " . blessed($self) . " into TAEB::World::Tile (temporarily) because Moose doesn't let us rebless into sibling classes.");
    }

    TAEB->debug("Reblessing a " . blessed($self) . " into $new_pkg.");

    # and do the rebless, which does all the typechecking and whatnot
    $new_pkg->meta->rebless_instance($self);
}

sub downgrade {
    my $self = shift;

    return $self if blessed($self) eq 'TAEB::World::Tile';

    my $msg  = shift
            || "Reblessing " . blessed($self) . " into TAEB::World::Tile.";

    TAEB->debug($msg);
    bless $self => 'TAEB::World::Tile';
}

sub has_monster {
    my $self = shift;

    # rationale: TAEB is no monster, he's just misunderstood
    return 0 if $self->x == TAEB->x
             && $self->y == TAEB->y;

    # XXX: @ is currently not included because of shks
    $self->glyph =~ /[a-zA-Z&';:1-5]/;
}

sub is_walkable {
    my $self = shift;

    # current tile is always walkable
    return 1 if $self->x == TAEB->x
             && $self->y == TAEB->y;

    # XXX: yes. I know. shut up.
    return 0 if $self->glyph eq '0' || $self->glyph eq '@';

    # obscured is probably walkable
    # XXX: fish
    return 1 if $self->type eq 'obscured';

    # quick hack for doors
    return 1 if $self->type eq 'opendoor';

    $self->floor_glyph =~ /[.<>^\\_{#]/;
}

sub step_on {
    my $self = shift;

    $self->stepped_on($self->stepped_on + 1);
    $self->explored(1);
}

sub each_adjacent {
    my $self = shift;
    my $code = shift;

    $self->each_orthogonal($code);
    $self->each_diagonal($code);
}

sub each_adjacent_inclusive {
    my $self = shift;
    my $code = shift;

    $code->($self, '.');
    $self->each_adjacent($code);
}

sub each_orthogonal {
    my $self  = shift;
    my $code  = shift;

    my $level = $self->level;
    my $x     = $self->x;
    my $y     = $self->y;

    for my $dy (-1 .. 1) {
        for my $dx (-1 .. 1) {
            next unless $dy || $dx; # skip 0, 0
            next if $dy && $dx; # skip diagonals

            my $dir = delta2vi($dx, $dy);

            my $tile = $level->at(
                $dx + $x,
                $dy + $y,
            );

            if (!defined($tile)) {
                next;
            }

            $code->($tile, $dir);
        }
    }
}

sub each_diagonal {
    my $self  = shift;
    my $code  = shift;

    my $level = $self->level;
    my $x     = $self->x;
    my $y     = $self->y;

    for my $dy (-1 .. 1) {
        for my $dx (-1 .. 1) {
            next unless $dy || $dx; # skip 0, 0
            next unless $dy && $dx; # skip orthogonals

            my $dir = delta2vi($dx, $dy);

            my $tile = $level->at(
                $dx + $x,
                $dy + $y,
            );

            if (!defined($tile)) {
                next;
            }

            $code->($tile, $dir);
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

make_immutable;

1;


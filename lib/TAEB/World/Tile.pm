#!/usr/bin/env perl
package TAEB::World::Tile;
use TAEB::OO;
use TAEB::Util qw/glyph_to_type delta2vi glyph_is_monster/;
use List::MoreUtils qw/any all apply/;

has level => (
    isa      => 'TAEB::World::Level',
    weak_ref => 1,
    required => 1,
    handles  => [qw/z/],
);

#has room => (
#    isa      => 'TAEB::World::Room',
#    weak_ref => 1,
#);

has type => (
    isa     => 'TileType',
    default => 'rock',
    trigger => sub {
        my $self = shift;
        $self->rebless(@_);
    },
);

has glyph => (
    isa     => 'Str',
    default => ' ',
);

has floor_glyph => (
    isa     => 'Str',
    default => ' ',
);

has stepped_on => (
    isa     => 'Int',
    default => 0,
);

has x => (
    isa      => 'Int',
    required => 1,
);

has y => (
    isa      => 'Int',
    required => 1,
);

has searched => (
    isa     => 'Int',
    default => 0,
);

has explored => (
    isa     => 'Bool',
    default => 0,
);

has engraving => (
    isa     => 'Str',
    default => '',
);

has interesting_at => (
    isa     => 'Int',
    default => 0,
);

has monster => (
    isa     => 'TAEB::World::Monster',
    clearer => 'clear_monster',
);

has items => (
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef[TAEB::World::Item]',
    default    => sub { [] },
    auto_deref => 1,
    provides   => {
        push   => 'add_item',
        clear  => 'clear_items',
        delete => 'remove_item',
        count  => 'item_count',
    },
);

has last_stepped => (
    isa           => 'Int',
    default       => 0,
    documentation => "The last turn that we were on this tile",
);

has in_shop => (
    isa           => 'Bool',
    default       => 0,
    documentation => "Is this tile inside a shop?",
);

=head2 basic_cost -> Int

This returns the basic cost of entering a tile. It's not very smart, but it
should do the trick for avoiding known traps and preferring the trodden path.

=cut

sub basic_cost {
    my $self = shift;
    my $cost = 100;

    $cost = 1000 if $self->type eq 'trap';

    # prefer tiles we've stepped on to avoid traps
    $cost = $cost * .9 if $self->stepped_on;

    # prefer rooms to corridors to explore a bit more sanely
    $cost = $cost * 1.05 if $self->type eq 'corridor';

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
    $self->clear_monster;

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
        $self->try_monster($newglyph, $color);

        # ghosts and xorns should not update the map
        return if $newglyph eq 'X';

        $self->interesting_at(TAEB->turn)
            unless $self->monster;

        $self->type('obscured')
            if $oldtype eq 'rock'
            || $oldtype eq 'closeddoor';

        return;
    }

    $self->change_type($newtype => $newglyph);
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
    $self->last_stepped(TAEB->turn);
}

sub iterate_tiles {
    my $self       = shift;
    my $controller = shift;
    my $usercode   = shift;
    my $directions = shift;

    if ($self->y <= 0) {
        TAEB->error("" . (caller 1)[3] . " called with a y argument of ".$self->y.". This usually indicates an unhandled prompt.");
    }

    my @tiles = grep { defined } map {
                                     $self->level->at(
                                         $self->x + $_->[0],
                                         $self->y + $_->[1]
                                     )
                                 } @$directions;

    $controller->(sub {
        my $tile = $_;
        my ($dx, $dy) = ($tile->x - $self->x, $tile->y - $self->y);
        my $dir = delta2vi($dx, $dy);
        $usercode->($tile, $dir);
    }, @tiles);
}

my %tiletypes = (
    diagonal => [
        [-1, -1],          [-1, 1],

        [ 1, -1],          [ 1, 1],
    ],
    orthogonal => [
                  [-1, 0],
        [ 0, -1],          [ 0, 1],
                  [ 1, 0],
    ],
    adjacent => [
        [-1, -1], [-1, 0], [-1, 1],
        [ 0, -1],          [ 0, 1],
        [ 1, -1], [ 1, 0], [ 1, 1],
    ],
    adjacent_inclusive => [
        [-1, -1], [-1, 0], [-1, 1],
        [ 0, -1], [ 0, 0], [ 0, 1],
        [ 1, -1], [ 1, 0], [ 1, 1],
    ],
);
my %controllers = (
    each => \&apply,
    all  => \&all,
    any  => \&any,
);

for my $tiletype (keys %tiletypes) {
    for my $name (keys %controllers) {
        __PACKAGE__->meta->add_method("${name}_${tiletype}" => sub {
            my $self = shift;
            my $code = shift;
            $self->iterate_tiles($controllers{$name},
                                 $code,
                                 $tiletypes{$tiletype})
        })
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

sub might_have_new_item {
    my $self = shift;
    return $self->interesting_at > $self->last_stepped + 1
        || $self->type eq 'obscured' && $self->last_stepped == 0;
}

sub elbereths {
    my $self = shift;
    my $engraving = $self->engraving;
    return $engraving =~ s/elbereth//gi || 0;
}

sub floodfill {
    my $self               = shift;
    my $continue_condition = shift;
    my $update_tile        = shift;

    return unless $continue_condition->($self);

    my @queue = $self;
    my %seen;

    while (my $tile = shift @queue) {
        next if $seen{$tile}++;
        $update_tile->($tile);

        $tile->each_adjacent(sub {
            my $t = shift;
            if (!$seen{$t} && $continue_condition->($t)) {
                push @queue, $t;
            }
        });
    }
}

sub change_type {
    my $self     = shift;
    my $newtype  = shift;
    my $newglyph = shift;

    return if $self->type eq $newtype && $self->floor_glyph eq $newglyph;

    TAEB->enqueue_message('tile_update' => $self);

    $self->type($newtype);
    $self->floor_glyph($newglyph);
}

sub debug_line {
    my $self = shift;
    (my $class = blessed $self) =~ s/^TAEB::World:://;

    my $engraving = $self->engraving
                  ? length($self->engraving) . '/' . $self->elbereths . ' '
                  : '';

    sprintf '(%d, %d) g="%s" f="%s" t="%s" i=%d%s%s%s c="%s"',
            $self->x,
            $self->y,
            $self->glyph,
            $self->floor_glyph,
            $self->type,
            $self->item_count,
            $self->might_have_new_item ? '*' : '',
            $self->in_shop ? ' shop' : '',
            $engraving,
            $class;
}

sub try_monster {
    my $self  = shift;
    my $glyph = shift;
    my $color = shift;

    return unless glyph_is_monster($glyph);
    return if TAEB->x == $self->x && TAEB->y == $self->y;

    $self->monster(TAEB::World::Monster->new(
        glyph => $glyph,
        color => $color,
        tile  => $self,
    ));
}

sub has_enemy {
    my $monster = shift->monster
        or return 0;
    return $monster->is_enemy ? $monster : undef;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


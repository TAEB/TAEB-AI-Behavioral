#!/usr/bin/env perl
package TAEB::World::Tile;
use TAEB::OO;
use TAEB::Util qw/glyph_to_type delta2vi glyph_is_monster :colors/;
use List::MoreUtils qw/any all apply/;

use overload %TAEB::Meta::Overload::default;

has level => (
    isa      => 'TAEB::World::Level',
    weak_ref => 1,
    required => 1,
    handles  => [qw/z branch/],
);

#has room => (
#    isa      => 'TAEB::World::Room',
#    weak_ref => 1,
#);

has type => (
    isa     => 'TileType',
    default => 'rock',
);

has glyph => (
    isa     => 'Str',
    default => ' ',
);

has floor_glyph => (
    isa     => 'Str',
    default => ' ',
);

has color => (
    isa     => 'Int',
    default => 0,
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
    trigger => sub {
        my $self = shift;
        my $engraving = shift;
        if (length($engraving) > 255) {
            $self->engraving(substr($engraving, 0, 255));
        }
    },
);

has engraving_type => (
    isa     => 'Str',
    default => '',
    documentation => "Store the writing type",
);

has interesting_at => (
    isa     => 'Int',
    default => 0,
);

has monster => (
    isa     => 'TAEB::World::Monster',
    clearer => '_clear_monster',
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

has last_step => (
    isa           => 'Int',
    default       => 0,
    documentation => "The last step that we were on this tile",
);

has last_turn => (
    isa           => 'Int',
    default       => 0,
    documentation => "The last turn that we were on this tile",
);

has in_shop => (
    isa           => 'Bool',
    default       => 0,
    documentation => "Is this tile inside a shop?",
);

has in_temple => (
    isa           => 'Bool',
    default       => 0,
    documentation => "Is this tile inside a temple?",
);

has in_vault => (
    isa           => 'Bool',
    default       => 0,
    documentation => "Is this tile inside a vault?",
);

has in_zoo => (
    isa           => 'Bool',
    default       => 0,
    documentation => "Is this tile inside a zoo?",
);

has pathfind => (
    isa           => 'Int',
    default       => 0,
    documentation => "How many times this tile has been expanded in a pathfind this step",
);

=head2 basic_cost -> Int

This returns the basic cost of entering a tile. It's not very smart, but it
should do the trick for avoiding known traps and preferring the trodden path.

=cut

sub basic_cost {
    my $self = shift;
    my $cost = 100;

    $cost *= 20 if defined $self->monster;
    $cost *= 10 if $self->type eq 'trap';
    $cost *= 4  if $self->type eq 'ice';

    # prefer tiles we've stepped on to avoid traps
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
    $self->color($color);

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

        $self->interesting_at(TAEB->step)
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

    my $old_pkg = blessed $self;
    my $new_pkg = "TAEB::World::Tile::\L\u$newtype";

    $self->unblessed($old_pkg => $new_pkg);

    # if the new_pkg doesn't exist, then just go with the regular Tile
    return $self->downgrade unless eval { local $SIG{__DIE__}; $new_pkg->meta };

    # no work to be done, yay
    return if blessed($self) eq $new_pkg;

    # are we a superclass of the new package? if not, we need to revert
    # to a regular Tile so we can be reblessed into a subclass of Tile
    # in other words, Moose doesn't let you rebless into a sibling class
    unless (eval { local $SIG{__DIE__}; $new_pkg->isa(blessed($self)) }) {
        $self->downgrade("Reblessing a " . blessed($self) . " into TAEB::World::Tile (temporarily) because Moose doesn't let us rebless into sibling classes.");
    }

    TAEB->debug("Reblessing a " . blessed($self) . " into $new_pkg.");

    # and do the rebless, which does all the typechecking and whatnot
    $new_pkg->meta->rebless_instance($self);
    $self->reblessed($old_pkg => $new_pkg);
}

sub unblessed { }
sub reblessed { }

sub downgrade {
    my $self = shift;

    return $self if blessed($self) eq 'TAEB::World::Tile';

    my $msg  = shift
            || "Reblessing " . blessed($self) . " into TAEB::World::Tile.";

    TAEB->debug($msg);
    bless $self => 'TAEB::World::Tile';
}

my %is_walkable = map { $_ => 1 } qw/stairsdown stairsup trap altar opendoor floor ice grave throne sink fountain corridor/;
sub is_walkable {
    my $self = shift;
    my $through_unknown = shift;

    # current tile is always walkable
    return 1 if $self->x == TAEB->x
             && $self->y == TAEB->y;

    return 0 if $self->y < 1 || $self->y > 21;

    # XXX: yes. I know. shut up.
    return 0 if $self->glyph eq '0';

    # we can path through unlit areas that we haven't seen as rock for sure yet
    return 1 if $through_unknown &&
                $self->type eq 'rock' &&
                $self->all_adjacent(sub { shift->stepped_on == 0 });

    return $is_walkable{ $self->type };
}

sub step_on {
    my $self = shift;

    $self->stepped_on($self->stepped_on + 1);
    $self->explored(1);
    $self->last_turn(TAEB->turn);
    $self->last_step(TAEB->step);
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
    grep => sub { my $code = shift; grep { $code->($_) } @_ },
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

sub might_have_new_item {
    my $self = shift;
    return $self->interesting_at > $self->last_step + 1
        || $self->type eq 'obscured' && $self->last_step == 0;
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

    $self->level->unregister_tile($self);

    $self->type($newtype);
    $self->floor_glyph($newglyph);

    $self->level->register_tile($self);

    $self->rebless($newtype);
}

sub debug_line {
    my $self = shift;
    my @bits;

    push @bits, sprintf '(%d,%d)', $self->x, $self->y;
    push @bits, $1 if (blessed $self) =~ /TAEB::World::Tile::(.+)/;
    push @bits, 't=' . $self->type;

    push @bits, 'g<' . $self->glyph . '>';
    push @bits, 'f<' . $self->floor_glyph . '>'
        if $self->glyph ne $self->floor_glyph;

    push @bits, sprintf 'i=%d%s',
                    $self->item_count,
                    $self->might_have_new_item ? '*' : '';

    if ($self->engraving) {
        push @bits, sprintf 'E=%d/%d',
                        length($self->engraving),
                        $self->elbereths;
    }

    push @bits, 'shop'  if $self->in_shop;
    push @bits, 'vault' if $self->in_vault;

    if ($self->has_enemy) {
        push @bits, 'enemy';
    }
    elsif ($self->monster) {
        push @bits, 'monster';
    }

    return join ' ', @bits;
}

sub try_monster {
    my $self  = shift;
    my $glyph = shift;
    my $color = shift;

    $self->_clear_monster if $self->monster;

    return if TAEB->x == $self->x && TAEB->y == $self->y;
    if (!TAEB->is_blind &&
         TAEB->current_level->is_rogue &&
         $glyph eq ' ') {
        return unless ($self->all_adjacent(sub { shift->floor_glyph ne ' ' })
                       || (defined $self->floor_glyph
                           && $self->floor_glyph ne ' '))
                   &&  $self->any_adjacent(sub {
                           my $self = shift;
                           return $self->x eq TAEB->x
                               && $self->y eq TAEB->y
                       });
        $self->monster(TAEB::World::Monster->new(
            glyph => 'X',
            color => COLOR_GRAY,
            tile  => $self,
        ));
    }
    else {
        return unless glyph_is_monster($glyph);

        $self->monster(TAEB::World::Monster->new(
            glyph => $glyph,
            color => $color,
            tile  => $self,
        ));
    }

    $self->level->add_monster($self->monster);
}

before _clear_monster => sub {
    my $self = shift;
    $self->level->remove_monster($self->monster);
};

sub has_enemy {
    my $monster = shift->monster
        or return 0;
    return $monster->is_enemy ? $monster : undef;
}

sub has_friendly {
    my $monster = shift->monster
        or return 0;
    return $monster->is_enemy ? undef : $monster;
}

sub searchability {
    my $self = shift;
    my $searchability = 0;

    $self->each_adjacent(sub {
        my $tile = shift;
        return unless $tile->type eq 'wall' || $tile->type eq 'rock';
        return unless $tile->searched < 30;
        $searchability += 30 - $tile->searched;
    });

    return $searchability;
}

sub draw_normal {
    my $self           = shift;
    my $display_method = shift;

    my $color = $self->color;
    my $bold  = 0;

    if ($color >= 8) {
        $color -= 8;
        $bold  = Curses::A_BOLD;
    }

    Curses::addch($bold | Curses::COLOR_PAIR($color) | ord $self->$display_method);
}

sub draw_debug {
    my $self           = shift;
    my $display_method = shift;

    my $path  = TAEB->action && TAEB->action->can('path') && TAEB->action->path;
    my $color;

    if ($path) {
        $color = Curses::COLOR_PAIR(COLOR_MAGENTA)
            if $path->contains_tile($self) && $path->from ne $self;
        $color |= Curses::A_BOLD
            if $path->to eq $self;
    }

    $color ||= $self->in_shop || $self->in_temple
             ? Curses::COLOR_PAIR(COLOR_GREEN) | Curses::A_BOLD
             : $self->monster && $self->monster->is_enemy
             ? Curses::COLOR_PAIR(COLOR_RED) | Curses::A_BOLD
             : $self->might_have_new_item
             ? Curses::COLOR_PAIR(COLOR_RED)
             : $self->searched > 5
             ? Curses::COLOR_PAIR(COLOR_CYAN)
             : $self->stepped_on
             ? Curses::COLOR_PAIR(COLOR_BROWN)
             : $self->explored
             ? Curses::COLOR_PAIR(COLOR_GREEN)
             : 0;

    Curses::addch($color | ord $self->$display_method);
}

sub draw_pathfind {
    my $self           = shift;
    my $display_method = shift;

    my $pathfind = $self->pathfind;

    my $color = $pathfind == 0 ? 0
              : $pathfind == 1 ? Curses::COLOR_PAIR(COLOR_RED)
              : $pathfind == 2 ? Curses::COLOR_PAIR(COLOR_BROWN)
              : $pathfind == 3 ? Curses::COLOR_PAIR(COLOR_GREEN)
                               : Curses::COLOR_PAIR(COLOR_MAGENTA);

    Curses::addch($color | ord $self->$display_method);
}


sub display_glyph {
    my $self = shift;
    $self->glyph eq ' ' ? $self->floor_glyph : $self->glyph;
}

sub display_floor {
    my $self = shift;
    $self->floor_glyph;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


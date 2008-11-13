#!/usr/bin/env perl
package TAEB::World::Tile;
use TAEB::OO;
use TAEB::Util qw/delta2vi vi2delta :colors/;
use List::MoreUtils qw/any all apply/;

with 'TAEB::Meta::Role::Reblessing';

use overload %TAEB::Meta::Overload::default;

has level => (
    isa      => 'TAEB::World::Level',
    weak_ref => 1,
    required => 1,
    handles  => [qw/z known_branch branch glyph_to_type/],
);

#has room => (
#    isa      => 'TAEB::World::Room',
#    weak_ref => 1,
#);

has type => (
    isa     => 'TAEB::Type::Tile',
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
    metaclass => 'Counter',
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
    metaclass => 'Counter',
);

has explored => (
    isa      => 'Bool',
    default  => 0,
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

has is_interesting => (
    isa     => 'Bool',
    default => 0,
    writer  => 'set_interesting',
);

has monster => (
    isa       => 'TAEB::World::Monster',
    clearer   => '_clear_monster',
    predicate => 'has_monster',
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

has is_lit => (
    isa           => 'Bool',
    default       => 1,
    documentation => "Is this tile probably lit?  Will usually be wrong except on floor and corridors.",
);

has pathfind => (
    metaclass => 'Counter',
    documentation => "How many times this tile has been expanded in a pathfind this step",
);

has kill_times => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef',
    default   => sub { [] },
    provides  => {
        push  => '_add_kill_time',
        clear => '_clear_kill_times',
    },
    documentation => "Kills which have been committed on this tile.  " .
        "Each element is an arrayref with a monster name, a turn number, " .
        "and a force_verboten (used for unseen kills) flag.",
);

=head2 basic_cost -> Int

This returns the basic cost of entering a tile. It's not very smart, but it
should do the trick for avoiding known traps and preferring the trodden path.

=cut

sub basic_cost {
    my $self = shift;
    my $cost = 100;

    $cost *= 20 if $self->has_monster;
    $cost *= 10 if $self->type eq 'trap';
    $cost *= 4  if $self->type eq 'ice';

    # prefer tiles we've stepped on to avoid traps
    $cost = $cost * .9 if $self->stepped_on;

    return int($cost);
}

sub update {
    my $self        = shift;
    my $newglyph    = shift;
    my $color       = shift;
    my $oldtype     = $self->type;
    my $hadfriendly = $self->has_friendly;

    # gas spore explosions should not update the map
    return if $newglyph =~ m{^[\\/-]$} && $color == 1;

    $self->glyph($newglyph);
    $self->color($color);

    $self->update_lit;

    # dark rooms
    return if $self->glyph eq ' ' && $self->floor_glyph eq '.';

    my $newtype = $self->glyph_to_type($newglyph, $color);

    # if we unveil a square and it was previously rock, then it's obscured
    # perhaps we entered a room and a tile changed from ' ' to '!'
    # if the tile's type was anything else, then it *became* obscured, and we
    # don't want to change what we know about it
    # XXX: if the type is olddoor then we probably kicked/opened the door and
    # something walked onto it. this needs improvement
    if ($newtype eq 'obscured') {
        # ghosts and xorns should not update the map
        return if $newglyph eq 'X';

        $self->set_interesting(1)
            unless $self->has_monster
                || $self->has_boulder
                || $hadfriendly; # if a friendly stepped off it, we don't
                                 # want it marked as interesting.

        $self->type('obscured')
            if $oldtype eq 'rock'
            || $oldtype eq 'closeddoor';

        return;
    } else {
        # If the tile is not obscured, there are no items on it.
        $self->clear_items;
    }

    $self->change_type($newtype => $newglyph);
}

my %is_walkable = map { $_ => 1 } qw/obscured stairsdown stairsup trap altar opendoor floor ice grave throne sink fountain corridor/;
sub is_walkable {
    my $self = shift;
    my $through_unknown = shift;

    # current tile is always walkable
    return 1 if $self->x == TAEB->x
             && $self->y == TAEB->y;

    # XXX: yes. I know. shut up.
    return 0 if $self->has_boulder;

    # we can path through unlit areas that we haven't seen as rock for sure yet
    return 1 if $through_unknown &&
                $self->type eq 'rock' &&
                $self->all_adjacent(sub { shift->stepped_on == 0 });

    return $is_walkable{ $self->type };
}

sub update_lit {
    my $self = shift;

    $self->is_lit(1) if $self->glyph eq '.' && !$self->is_lit
        (abs(TAEB->x - $self->x) > 1 || abs(TAEB->y - $self->y) > 1);
        #FIXME when TAEB supports lamp usage
    $self->is_lit(0) if $self->glyph eq ' ' && $self->floor_glyph eq '.';

    $self->is_lit($self->color == 15) if $self->glyph eq '#';
}

sub step_on {
    my $self = shift;

    $self->inc_stepped_on;
    $self->explored(1);
    $self->last_turn(TAEB->turn);
    $self->last_step(TAEB->step);
    $self->set_interesting(0);
}

sub step_off {
    my $self = shift;

    $self->set_interesting(0);

    if ($self->level == TAEB->current_level) {
        # When we step off a tile, anything that's nearby and still . is lit
        $self->each_adjacent(sub {
            my ($tile, $dir) = @_;
            $tile->is_lit(1) if $tile->glyph eq '.';
        });
    }
}

sub witness_kill {
    my ($self, $critter) = @_;

    $self->_add_kill_time([ $critter, TAEB->turn, 0 ]);
}

sub iterate_tiles {
    my $self       = shift;
    my $controller = shift;
    my $usercode   = shift;
    my $directions = shift;

    my ($x, $y) = ($self->x, $self->y);

    if ($y <= 0) {
        TAEB->error("" . (caller 1)[3] . " called with a y argument of ".$self->y.". This usually indicates an unhandled prompt.");
    }

    my $level = $self->level;

    my @tiles = grep { defined } map {
                                     $level->at(
                                         $x + $_->[0],
                                         $y + $_->[1]
                                     )
                                 } @$directions;

    $controller->(sub {
        $usercode->($_, delta2vi($_->x - $x, $_->y - $y));
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

sub base_class { __PACKAGE__ }

sub change_type {
    my $self     = shift;
    my $newtype  = shift;
    my $newglyph = shift;

    return if $self->type eq $newtype && $self->floor_glyph eq $newglyph;
    return if TAEB->current_level->is_rogue && $self->type eq 'stairsup';
    TAEB->enqueue_message('tile_update' => $self);

    $self->level->unregister_tile($self);

    $self->type($newtype);
    $self->floor_glyph($newglyph);

    $self->level->register_tile($self);

    $self->rebless("TAEB::World::Tile::\L\u$newtype");
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
                    $self->is_interesting ? '*' : '';

    if ($self->engraving) {
        push @bits, sprintf 'E=%d/%d',
                        length($self->engraving),
                        $self->elbereths;
    }

    push @bits, 'lit'   if $self->is_lit;
    push @bits, 'shop'  if $self->in_shop;
    push @bits, 'vault' if $self->in_vault;

    if ($self->has_enemy) {
        push @bits, 'enemy';
    }
    elsif ($self->has_monster) {
        push @bits, 'monster';
    }

    my ($px, $py) = $self->_panel;
    push @bits, ("$px,$py" . ($self->_panel_empty($px,$py) ? "[empty]" : ""));

    return join ' ', @bits;
}

sub try_monster {
    my ($self, $glyph, $color) = @_;

    # attempt to handle ghosts on the rogue level, which are always the
    # same glyphs as rocks. rogue level ignores your glyph settings.
    if (!TAEB->is_blind && TAEB->current_level->is_rogue && $glyph eq ' ') {
        my $is_rock = $self->any_adjacent(sub {
            shift->floor_glyph eq ' '
        });

        return if $is_rock;

        my ($Tx, $Ty) = (TAEB->x, TAEB->y);
        my $adjacent_to_taeb = $self->any_adjacent(sub {
            $_[0]->x eq $Tx && $_[0]->y eq $Ty
        });

        return unless $adjacent_to_taeb;

        $glyph = 'X';
        $color = COLOR_GRAY;
    }
    else {
        return unless $self->level->glyph_is_monster($glyph);
    }

    my $monster = TAEB::World::Monster->new(
        glyph => $glyph,
        color => $color,
        tile  => $self,
    );

    $self->monster($monster);
    $self->level->add_monster($monster);
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

sub has_boulder { shift->glyph eq '0' }

sub _panel {
    my $self = shift;

    my $panelx = int($self->x / 5);
    my $panely = int(($self->y - 1) / 5);

    $panely = 3 if $panely == 4;

    return ($panelx, $panely);
}

sub _panel_empty {
    my ($self, $px, $py) = @_;

    my $sx = ($px) * 5;
    my $sy = ($py) * 5 + 1;
    my $ex = ($px + 1) * 5 - 1;
    my $ey = ($py + 1) * 5;

    return 0 if ($px < 0 || $py < 0 || $px >= 20 || $py >= 4);
        # No sense searching the edge of the universe

    $ey = 21 if $ey == 20;

    for my $y ($sy .. $ey) {
        for my $x ($sx .. $ex) {
            return 0 if !defined($self->level->at($x,$y))
                     || $self->level->at($x,$y)->type ne 'rock';
        }
    }

    return 1;
}

sub searchability {
    my $self = shift;
    my $searchability = 0;

    # If the square is in an 5x5 panel, and is next to a 5x5 panel which
    # is empty, it is considered much more searchable.  This should focus
    # searching efforts on parts of the map that matter.

    my (%n, $pdir);

    # probably a bottleneck; we shall see

    $self->each_adjacent(sub {
        my ($tile, $dir) = @_;
        return unless $tile->type eq 'wall' || $tile->type eq 'rock';
        return unless $tile->searched < 30;
        my $factor = 1;

        my ($px, $py) = $tile->_panel;
        my ($dx, $dy) = vi2delta $dir;

        if ($self->_panel_empty ($px+$dx, $py+$dy)) {
            $factor = $tile->type eq 'wall' ? 2000 : 100;
        }

        $searchability += $factor * (30 - $tile->searched);
    });

    return $searchability;
}

sub normal_color {
    my $self           = shift;

    my $color = $self->color;
    my $bold  = 0;

    if ($color >= 8) {
        $color -= 8;
        $bold  = Curses::A_BOLD;
    }

    return $bold | Curses::COLOR_PAIR($color);
}

sub debug_color {
    my $self = shift;

    my $path = TAEB->has_action
            && TAEB->action->can('path')
            && TAEB->action->path;

    my $color;

    if ($path) {
        $color = Curses::COLOR_PAIR(COLOR_MAGENTA)
            if $path->contains_tile($self) && $path->from ne $self;
        $color |= Curses::A_BOLD
            if $path->to eq $self;
    }

    $color ||= inner() ||
               ($self->in_shop || $self->in_temple
             ? Curses::COLOR_PAIR(COLOR_GREEN) | Curses::A_BOLD
             : $self->has_enemy
             ? Curses::COLOR_PAIR(COLOR_RED) | Curses::A_BOLD
             : $self->is_interesting
             ? Curses::COLOR_PAIR(COLOR_RED)
             : $self->searched > 5
             ? Curses::COLOR_PAIR(COLOR_CYAN)
             : $self->stepped_on
             ? Curses::COLOR_PAIR(COLOR_BROWN)
             : $self->explored
             ? Curses::COLOR_PAIR(COLOR_GREEN)
             : 0);

    $color |= Curses::A_REVERSE
        if $self->type eq 'rock'
        && $self->any_adjacent(sub { shift->explored });

    return $color;
}

sub pathfind_color {
    my $self           = shift;

    my $pathfind = $self->pathfind;

    my $color = $pathfind == 0 ? 0
              : $pathfind == 1 ? Curses::COLOR_PAIR(COLOR_RED)
              : $pathfind == 2 ? Curses::COLOR_PAIR(COLOR_BROWN)
              : $pathfind == 3 ? Curses::COLOR_PAIR(COLOR_GREEN)
                               : Curses::COLOR_PAIR(COLOR_MAGENTA);

    return $color;
}

sub lit_color {
    my $self = shift;

    return $self->is_lit
         ? Curses::COLOR_PAIR(COLOR_BROWN) | Curses::A_BOLD
         : Curses::COLOR_PAIR(COLOR_WHITE) | Curses::A_BOLD;
}

sub stepped_color {
    my $self = shift;
    my $stepped = $self->stepped_on;

    return Curses::COLOR_PAIR(COLOR_WHITE) | Curses::A_BOLD if $stepped == 0;
    return Curses::COLOR_PAIR(COLOR_RED)                    if $stepped == 1;
    return Curses::COLOR_PAIR(COLOR_RED) | Curses::A_BOLD   if $stepped == 2;
    return Curses::COLOR_PAIR(COLOR_BROWN)                  if $stepped < 5;
    return Curses::COLOR_PAIR(COLOR_BROWN) | Curses::A_BOLD if $stepped < 8;
    return Curses::COLOR_PAIR(COLOR_MAGENTA);
}

sub time_color {
    my $self = shift;
    my $last_turn = $self->last_turn;
    my $dt = TAEB->turn - $last_turn;

    return Curses::COLOR_PAIR(COLOR_WHITE) | Curses::A_BOLD   if $last_turn == 0;
    return Curses::COLOR_PAIR(COLOR_RED)                      if $dt > 1000;
    return Curses::COLOR_PAIR(COLOR_RED) | Curses::A_BOLD     if $dt > 500;
    return Curses::COLOR_PAIR(COLOR_BROWN)                    if $dt > 100;
    return Curses::COLOR_PAIR(COLOR_BROWN) | Curses::A_BOLD   if $dt > 50;
    return Curses::COLOR_PAIR(COLOR_MAGENTA)                  if $dt > 25;
    return Curses::COLOR_PAIR(COLOR_MAGENTA) | Curses::A_BOLD if $dt > 15;
    return Curses::COLOR_PAIR(COLOR_GREEN)                    if $dt > 10;
    return Curses::COLOR_PAIR(COLOR_GREEN) | Curses::A_BOLD   if $dt > 5;
    return Curses::COLOR_PAIR(COLOR_CYAN)                     if $dt > 3;
    return Curses::COLOR_PAIR(COLOR_CYAN) | Curses::A_BOLD;
}

sub engraving_color {
    my $self = shift;
    my $engraving = $self->engraving ne '';
    my $bold = $self->elbereths == 0 ? Curses::A_NORMAL : Curses::A_BOLD;

    return $engraving
         ? Curses::COLOR_PAIR(COLOR_GREEN) | $bold
         : Curses::COLOR_PAIR(COLOR_BROWN);
}

sub normal_glyph {
    my $self = shift;
    $self->glyph eq ' ' ? $self->floor_glyph : $self->glyph;
}

sub farlooked {}

# keep track of our items on the level object {{{
after add_item => sub {
    my $self = shift;
    push @{ $self->level->items }, @_;

    for my $item (@_) {
        next unless $item->class eq 'carrion';

        my @kl = @{ $self->kill_times };
        my ($date, $v) = (undef, 0);

        # I think this should be about 749, but the consequences of failure
        # are enough to motivate paranoia
        @kl = grep { $_->[1] >= TAEB->turn - 1000 } @kl;

        for my $kill (@kl) {
            my ($name, $age, $bad) = @$kill;

            if (my $body = TAEB::Spoilers::Monster->monster($name)->
                    {corpse}->{undead}) {
                $name = $body;
                $age -= 100;
            }

            next unless $name eq $item->monster;

            if (!defined($date) || $date > $age) {
                $date = $age;
            }

            $v ||= $bad;
        }

        if (!defined($date)) {
            # This corpse has no kill record!  It must have died out of sight.
            push @kl, [ $item->monster, TAEB->turn, 1 ];
            $date = TAEB->turn;
            $v = 1;
        }

        $item->estimated_date($date);
        $item->is_forced_verboten($v);

        @{ $self->kill_times } = @kl;
    }
};

before clear_items => sub {
    my $self = shift;
    for ($self->items) {
        $self->_remove_level_item($_);
    }
};

before remove_item => sub {
    my $self = shift;
    my $idx = shift;
    $self->_remove_level_item($self->items->[$idx]);
};

sub _remove_level_item {
    my $self = shift;
    my $item = shift;
    my $level = $self->level;

    for my $i (0 .. $level->item_count - 1) {
        my $level_item = $level->items->[$i];
        if ($item == $level_item) {
            splice @{ $level->items }, $i, 1;
            return;
        }
    }
}
# }}}

# keep track of which tiles are interesting on the level object
before set_interesting => sub {
    my $self = shift;
    my $set = shift(@_) ? 1 : 0;

    my $is_interesting = $self->is_interesting ? 1 : 0;

    # no change? don't care
    return if $set == $is_interesting;

    if ($set) {
        $self->level->register_tile($self => 'interesting');
    }
    else {
        $self->level->unregister_tile($self => 'interesting');
    }
};

=head2 is_empty -> Bool

Returns true if the tile is free from items, monsters, boulders, and the player
character.

It *can* have a dungeon feature, such as a fountain.

=cut

sub is_empty {
    my $self = shift;

    # probably okay for now, we may want to check items monster etc explicitly
    # though
    return $self->glyph eq $self->floor_glyph;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


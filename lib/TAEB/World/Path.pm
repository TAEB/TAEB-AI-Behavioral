#!/usr/bin/env perl
package TAEB::World::Path;
use TAEB::OO;
use Heap::Simple;
use TAEB::Util 'delta2vi', 'deltas';
use List::Util 'sum', 'max';
use Scalar::Util 'refaddr';
use Time::HiRes 'time';

has from => (
    is       => 'ro',
    isa      => 'TAEB::World::Tile',
    required => 1,
);

has to => (
    is       => 'ro',
    isa      => 'TAEB::World::Tile',
    required => 1,
);

has path => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has complete => (
    is       => 'ro',
    isa      => 'Bool',
    required => 1,
);

has tiles => (
    is      => 'ro',
    isa     => 'HashRef[Int]',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $in   = {};
        my $tile = $self->from;

        for (split '', $self->path) {
            last if ++$in->{refaddr $tile} >= 2;
            $tile = $tile->level->at_direction($tile->x, $tile->y, $_)
                or last;
        }

        $in->{ refaddr $self->to } ||= 1;

        return $in;
    },
);

sub new {
    confess "You shouldn't call TAEB::World::Path->new directly. Use one of its path creation methods.";
}

=head2 calculate_path [Tile,] Tile -> Path

Calculates the best path from Tile 1 to Tile 2. Returns the path object. If the
path is incomplete, it probably leads to some unexplored area between the two
tiles.

The path may not necessarily be the shortest one. It may relax the path a bit
to avoid a dangerous trap, for example.

The "from" tile is optional. If elided, TAEB's current tile will be used.

=cut

sub calculate_path {
    my $class = shift;
    my $from  = @_ > 1 && @_ % 2 == 0 ? shift : TAEB->current_tile;
    my $to    = shift;
    my %args  = @_;

    my ($path, $complete) = $class->_calculate_path($from, $to, %args);

    if ($complete && $args{traverse_destination} && $to->can('traverse_command')) {
        $path .= $to->traverse_command;
    }

    Moose::Object::new($class,
        from     => $from,
        to       => $to,
        path     => $path,
        complete => $complete,
    );
}

=head2 first_match Code, ARGS -> Maybe Path

This will return a path to the first tile for which the coderef returns a true
value.

=cut

sub first_match {
    my $class = shift;
    my $code = shift;
    return $class->max_match(sub { $code->(@_) ? 'q' : undef }, @_);
}

=head2 max_match Code, ARGS -> Maybe Path

This will return a path to the first tile for which the coderef returns the
maximum value.

=cut

sub max_match {
    my $class = shift;
    my $code  = shift;
    my %args = @_;
    $args{from}     ||= TAEB->current_tile;
    $args{on_level} ||= TAEB->current_level;

    my ($to, $path);
    if ($args{on_level} != TAEB->current_level) {
        my $exit = $args{on_level}->exit_towards(TAEB->current_level)
            or return;

        my $complete;
        ($path, $complete) = $class->_calculate_path(
            $args{from} => $exit,
            why => $args{why},
        );
        if (!$complete) {
            $args{interlevel_failure}->() if exists $args{interlevel_failure};
            return;
        }

        my $intralevel_path;
        ($to, $intralevel_path) = $class->_dijkstra($code,
                                                    (%args, from => $exit));
        if (!defined $intralevel_path) {
            $args{intralevel_failure}->() if exists $args{intralevel_failure};
            return;
        }

        $path .= $intralevel_path;
    }
    else {
        ($to, $path) = $class->_dijkstra($code, %args);
        if (!defined $path) {
            $args{intralevel_failure}->() if exists $args{intralevel_failure};
            return;
        }
    }

    $to or return;

    Moose::Object::new($class,
        from     => $args{from},
        to       => $to,
        path     => $path,
        complete => 1,
    );
}

=head2 _calculate_path Tile, Tile[, ARGS] -> Str, Bool

Used internally by calculate_path -- returns just (path, complete).

=cut

sub _calculate_path {
    my $class = shift;
    my $from  = shift;
    my $to    = shift;
    my $path  = '';

    while ($from->level != $to->level) {
        my $exit = $from->level->exit_towards($to->level);
        return ($path, 0) if !$exit;
        my ($p, $c) = $class->_calculate_intralevel_path($from, $exit, @_);

        $path .= $p;
        $path .= $exit->traverse_command;

        $from = $exit->other_side;

        return ($path, 0) if !$c;
    }

    my ($p, $c) = $class->_calculate_intralevel_path($from, $to, @_);

    $path .= $p if defined $p;

    return ($path, $c);
}

=head2 _calculate_intralevel_path Tile, Tile[, ARGS] -> Str, Bool

Same as _calculate_path, except the Tiles are supposed to be on the same level.
This is to simplify some internals. The results are undefined if the tiles
are not on the same level (most likely there'll be a controlled detonation).

=cut

sub _calculate_intralevel_path {
    my $class = shift;
    my $from  = shift;
    my $to    = shift;

    return ('', 1) if $from == $to;

    if ($from->level != $to->level) {
        confess "_calculate_intralevel_path called on tiles that weren't on the same level.";
    }

    my $path = $class->_astar($to, @_, from => $from);

    return ($path, defined($path) && length($path) ? 1 : 0);
}

=head2 _dijkstra Code, ARGS -> Tile, Str

This performs a search for some tile. The code reference is evaluated for each
tile along the way. It receives the current tile, the path to it, and the
path's cost thus far as its arguments. It's expected to return one of the
following:

=over 4

=item The string 'q'

This indicates that the search may be short-circuited, returning this tile.
This can be used when searching for a known tile.

=item A number

This is used to score relative tiles. The tile with the maximum score will
be returned from C<_dijkstra>.

=item C<undef>

This is used to indicate that the current tile is not a valid solution.

=back

The optional arguments are:

=over 4

=item from (default: TAEB->current_tile)

The starting tile

=item through_unknown (default: false)

Whether to assume unknown tiles are walkable

=item include_endpoints (default: false)

Whether to include nonwalkable endpoints in the scorer checks (in essence, do
you want to include monsters, walls, etc as targets?)

=item why (default: "unknown")

String used to identify caller in debugging output

=cut

sub _dijkstra {
    my $class  = shift;
    my $scorer = shift;
    my %args   = @_;

    TAEB->inc_pathfinds;

    my $from              = $args{from} || TAEB->current_tile;
    my $through_unknown   = $args{through_unknown};
    my $why               = $args{why} || "unknown";
    my $include_endpoints = $args{include_endpoints};
    my $sokoban           = $from->known_branch
                         && $from->branch eq 'sokoban';
    my $debug = TAEB->display->pathfinding;
    my $start;
    if ($debug) {
        $args{from}->level->each_tile(sub {
            shift->reset_pathfind;
        });
        $start = time;
    }

    my $max_score;
    my $max_tile;
    my $max_path;

    my @closed;

    my $pq = Heap::Simple->new(elements => "Any");
    $pq->key_insert(0, [$from, '']);

    while ($pq->count) {
        my $priority = $pq->top_key;
        my ($tile, $path) = @{ $pq->extract_top };
        $tile->inc_pathfind if $debug;

        my $score = $scorer->($tile, $path, $priority);
        if (defined $score) {
            if ($score eq 'q') {
                if ($debug) {
                    my $took = sprintf '%.4f', time - $start;
                    TAEB->redraw;
                    TAEB->notify("dijkstra $why ${took}s (q: $path)");
                }
                return ($tile, $path);
            }

            if (!defined($max_score) || $score > $max_score) {
                ($max_score, $max_tile, $max_path) = ($score, $tile, $path);
            }
        }

        if ($include_endpoints) {
            next unless $tile->is_walkable($through_unknown);
        }

        my ($x, $y) = ($tile->x, $tile->y);

        for (deltas) {
            my ($dy, $dx) = @$_;
            my $xdx = $x + $dx;
            my $ydy = $y + $dy;

            next if $xdx < 0 || $xdx > 79;
            next if $ydy < 1 || $ydy > 21;

            next if $closed[$xdx][$ydy];

            # can't move diagonally if we have lots in our inventory
            # XXX: this should be 600, but we aren't going to be able to get
            # the weight exact
            if ((TAEB->inventory->weight > 500 || $sokoban) && $dx && $dy) {
                next unless $tile->level->at($xdx, $y)->is_walkable
                         || $tile->level->at($x, $ydy)->is_walkable;
            }

            # can't move diagonally off of doors
            next if $tile->isa('TAEB::World::Tile::Door')
                 && $dx
                 && $dy;

            my $next = $tile->level->at($xdx, $ydy)
                or next;

            # can't move diagonally onto doors
            next if $next->isa('TAEB::World::Tile::Door')
                 && $dx
                 && $dy;

            $closed[$xdx][$ydy] = 1;

            if (!$include_endpoints) {
                next unless $next->is_walkable($through_unknown);
            }

            my $dir = delta2vi($dx, $dy);
            my $cost = $next->intrinsic_cost;

            # ahh the things I do for aesthetics.
            $cost-- unless $dy && $dx;

            $pq->key_insert($cost + $priority, [$next, $path . $dir]);
        }
    }

    if ($debug) {
        my $took = sprintf '%.4f', time - $start;
        TAEB->redraw;
        if (defined($max_score)) {
            TAEB->notify("dijkstra $why ${took}s ($max_score: $max_path)");
        }
        else {
            TAEB->notify("dijkstra $why ${took}s (no path)");
        }
    }
    return ($max_tile, $max_path);
}

=head2 _astar Tile, ARGS -> Maybe[Str]

=cut

sub _astar {
    my $class  = shift;
    my $to     = shift;
    my %args   = @_;

    TAEB->inc_pathfinds;

    my ($tx, $ty) = ($to->x, $to->y);
    my $heur = $args{heuristic} || sub {
        return max(abs($tx - $_[0]->x), abs($ty - $_[0]->y));
    };

    my $from = $args{from} || TAEB->current_tile;
    my $through_unknown   = $args{through_unknown} || 0;
    my $why               = $args{why} || "unknown";
    my $sokoban           = $from->known_branch
                         && $from->branch eq 'sokoban';
    my $debug = TAEB->display->pathfinding;

    my $key = join ":", (refaddr($to), refaddr($from), $through_unknown);
    my $cache = $to->level->_astar_cache;
    return $cache->{$key} if exists $cache->{$key};

    my $start;
    if ($debug) {
        $args{from}->level->each_tile(sub {
            shift->reset_pathfind();
        });
        $start = time;
    }

    my @closed;

    my $pq = Heap::Simple->new(elements => "Any");
    $pq->key_insert(0, [$from, '']);

    while ($pq->count) {
        my $priority = $pq->top_key;
        my ($tile, $path) = @{ $pq->extract_top };
        $tile->inc_pathfind(1) if $debug;

        if ($tile == $to) {
            if ($debug) {
                my $took = sprintf '%.4f', time - $start;
                TAEB->redraw;
                TAEB->notify("A* $why ${took}s ($path)");
            }

            $cache->{$key} = $path;
            return $path;
        }

        my ($x, $y) = ($tile->x, $tile->y);

        for (deltas) {
            my ($dy, $dx) = @$_;
            my $xdx = $x + $dx;
            my $ydy = $y + $dy;

            next if $xdx < 0 || $xdx > 79;
            next if $ydy < 1 || $ydy > 21;

            next if $closed[$xdx][$ydy];

            # can't move diagonally if we have lots in our inventory
            # XXX: this should be 600, but we aren't going to be able to get
            # the weight exact
            if ((TAEB->inventory->weight > 500 || $sokoban) && $dx && $dy) {
                next unless $tile->level->at($xdx, $y)->is_walkable
                         || $tile->level->at($x, $ydy)->is_walkable;
            }

            # can't move diagonally off of doors
            next if $tile->type eq 'opendoor'
                 && $dx
                 && $dy;

            my $next = $tile->level->at($xdx, $ydy)
                or next;

            next unless $next->is_walkable($through_unknown);

            # can't move diagonally onto doors
            next if $next->type eq 'opendoor'
                 && $dx
                 && $dy;

            $closed[$xdx][$ydy] = 1;

            my $dir = delta2vi($dx, $dy);
            my $cost = $next->intrinsic_cost + $heur->($next);

            # ahh the things I do for aesthetics.
            $cost-- unless $dy && $dx;

            $pq->key_insert($cost + $priority, [$next, $path . $dir]);
        }
    }

    if ($debug) {
        my $took = sprintf '%.4f', time - $start;
        TAEB->redraw;
        TAEB->notify("A* $why ${took}s (no path)");
    }

    $cache->{$key} = undef;
    return undef;
}

sub contains_tile {
    my $self = shift;
    my $tile = shift;

    return $self->tiles->{refaddr $tile};
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


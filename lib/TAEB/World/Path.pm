#!/usr/bin/env perl
package TAEB::World::Path;
use TAEB::OO;
use Heap::Simple;
use TAEB::Util 'delta2vi', 'deltas';

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

sub new {
    confess "You shouldn't call TAEB::World::Path->new directly. Use one of its path creation methods.";
}

=head2 calculate_path [Tile,] Tile -> Path

Calculates the best path from Tile 1 to Tile 2. Returns the path as vi keys and
whether the path was complete. If the path is incomplete, it probably leads to
some unexplored area between the two tiles.

The path may not necessarily be the shortest one. It may relax the path a bit
to avoid a dangerous trap, for example.

The "from" tile is optional. If elided, TAEB's current tile will be used.

=cut

sub calculate_path {
    my $class = shift;
    my $from  = @_ > 1 ? shift : TAEB->current_tile;
    my $to    = shift;

    my ($path, $complete) = $class->_calculate_path($from, $to);

    Moose::Object::new($class,
        from     => $from,
        to       => $to,
        path     => $path,
        complete => $complete,
    );
}

=head2 first_match [Tile,] Code -> Maybe Path

This will return a path to the first tile for which the coderef returns a true
value.

The "from" tile is optional. If elided, TAEB's current tile will be used.

=cut

sub first_match {
    my $class = shift;
    my $from  = @_ > 1 ? shift : TAEB->current_tile;
    my $code  = shift;

    my ($to, $path) = $class->_dijkstra($from, sub {
        $code->(@_) ? 'q' : undef
    });

    $to or return;

    Moose::Object::new($class,
        from     => $from,
        to       => $to,
        path     => $path,
        complete => 1,
    );
}

=head2 max_match [Tile,] Code -> Maybe Path

This will return a path to the first tile for which the coderef returns the
maximum value.

The "from" tile is optional. If elided, TAEB's current tile will be used.

=cut

sub max_match {
    my $class = shift;
    my $from  = @_ > 1 ? shift : TAEB->current_tile;
    my $code  = shift;

    my ($to, $path) = $class->_dijkstra($from, $code);

    $to or return;

    Moose::Object::new($class,
        from     => $from,
        to       => $to,
        path     => $path,
        complete => 1,
    );
}

=head2 _calculate_path Tile, Tile -> Str, Bool

Used internally by calculate_path -- returns just (path, complete).

=cut

sub _calculate_path {
    my $class = shift;
    my $from  = shift;
    my $to    = shift;
    my $path  = '';

    while ($from->level ne $to->level) {
        my $stairs = $from->level->stairs_to($to);
        my ($p, $c) = $class->_calculate_intralevel_path($from, $stairs);

        $path .= $p;
        # XXX: append whatever we need to go from $from to $stairs->other_side

        $from  = $stairs->other_side;

        return ($path, 0) if !$c;
    }

    my ($p, $c) = $class->_calculate_intralevel_path($from, $to);

    $path .= $p;
    return ($path, $c);
}

=head2 _calculate_intralevel_path Tile, Tile -> Str, Bool

Same as _calculate_path, except the Tiles are supposed to be on the same level.
This is to simplify some internals. The results are undefined if the tiles
are not on the same level (most likely there'll be a controlled detonation).

=cut

sub _calculate_intralevel_path {
    my $class = shift;
    my $from  = shift;
    my $to    = shift;

    if ($from->level ne $to->level) {
        confess "_calculate_intralevel_path called on tiles that weren't on the same level.";
    }

    my $to_x = $to->x;
    my $to_y = $to->y;

    my ($tile, $path) = $class->_dijkstra($from, sub {
        my $tile = shift;
        $tile->x == $to_x && $tile->y == $to_y ? 'q' : undef
    });

    return ($path, length($path) ? 1 : 0);
}

=head2 _dijkstra Tile, Code -> Tile, Str

This performs a search for some tile. The starting tile is given as the first
argument. The code reference is evaluated for each tile along the way. It
receives the current tile and the path to it as its arguments. It's expected to
return one of the following:

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

=cut

my $debug_color = 0;

sub _dijkstra {
    my $class  = shift;
    my $from   = shift;
    my $scorer = shift;

    my ($debug, $debug_length);
    if ($debug = TAEB->config->debug_dijkstra) {
        $debug_length = $debug =~ /length/;
        $debug_color = ($debug_color + 1) % 6;
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
        my ($x, $y) = ($tile->x, $tile->y);

        TAEB->out(
            "\e[%d;%dH\e[%dm%s",
            1+$y, 1+$x, 31 + $debug_color,
            $debug_length ? length($path) > 9 ? 0 : length($path): $tile->glyph
        ) if $debug;

        my $score = $scorer->($tile, $path);
        if (defined $score) {
            if ($score eq 'q') {
                TAEB->out(
                    "\e[%d;%dH\e[m", 1+TAEB->y, 1+TAEB->x
                ) if $debug;

                return ($tile, $path);
            }

            if (!defined($max_score) || $score > $max_score) {
                ($max_score, $max_tile, $max_path) = ($score, $tile, $path);
            }
        }

        next unless $tile->is_walkable;

        for (deltas) {
            my ($dy, $dx) = @$_;
            my $xdx = $x + $dx;
            my $ydy = $y + $dy;

            next if $closed[$xdx][$ydy];

            # can't move diagonally off of doors
            next if $tile->type eq 'opendoor'
                    && $dx
                    && $dy;

            my $next = $tile->level->at($xdx, $ydy)
                or next;

            # can't move diagonally onto doors
            next if $next->type eq 'opendoor'
                    && $dx
                    && $dy;

            $closed[$xdx][$ydy] = 1;

            my $dir = delta2vi($dx, $dy);
            my $cost = $next->basic_cost;

            # ahh the things I do for aesthetics.
            $cost-- unless $dy && $dx;

            $pq->key_insert($cost + $priority, [$next, $path . $dir]);
        }
    }

    TAEB->out(
        "\e[%d;%dH\e[m", 1+TAEB->y, 1+TAEB->x
    ) if $debug;
    return ($max_tile, $max_path);
}

make_immutable;
no Moose;

1;


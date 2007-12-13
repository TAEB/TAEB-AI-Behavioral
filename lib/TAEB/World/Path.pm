#!/usr/bin/env perl
package TAEB::World::Path;
use Moose;
use TAEB::Util 'direction';
use List::Util 'shuffle';

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
    is  => 'rw',
    isa => 'Str',
);

has complete => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

sub BUILD {
    my $self = shift;
    $self->calculate_path
        unless defined $self->complete;
}

=head2 calculate_path Tile, Tile

This will calculate the path between the two tiles.

=cut

sub calculate_path {
    my $self = shift;
    my ($f, $t) = ($self->from, $self->to);

    my $path = '';
    my $complete = 0;

    while ($f->level ne $t->level) {
        my $stairs = $f->level->stairs_to($t);

        my ($p, $c) = $self->_calculate_intralevel_path($f, $stairs);
        goto DONE unless $c;

        $f = $stairs->other_side;
        $path .= $p;
    }

    my ($p, $c) = $self->_calculate_intralevel_path($f, $t);
    goto DONE unless $c;
    $path .= $p;
    $complete = 1;

    DONE:
    $self->path($path);
    $self->complete($complete);
}

=head2 calculate_intralevel_path Tile, Tile -> Path

Returns a new TAEB::World::Path of the path between the tiles. The tiles must
be on the same level. Returns C<undef> if there's no known path.

=cut

sub calculate_intralevel_path {
    my $self = shift;
    my ($from, $to) = @_;

    my ($path, $complete) = $self->_calculate_intralevel_path($from, $to);
    return unless $complete;

    $self->new(from => $from, to => $to, path => $path, complete => $complete);
}

=head2 _calculate_intralevel_path Tile, Tile -> Str

Actually does the calculation of the path to go from the first tile to the
second. It will return the directions required. If there is unavoidable
unexplored area between the two tiles, then C<undef> will be returned.

=cut

sub _calculate_intralevel_path {
    my $self = shift;
    my ($from, $to) = @_;

    my ($tile, $path) = $self->first_match_level($from, sub {
        my $tile = shift;
        return $tile->x && $to->x && $tile->y == $to->y;
    });

    return $path;
}

=head2 first_match_level Tile, Code -> Tile, Str

This takes a starting tile and a code reference, and does a breadth-first
search to the first tile that makes the code ref return true. It then returns
the matching tile and the path to it from the starting tile.

WARNING: Only the level of the starting tile will be searched.

=cut

sub first_match_level {
    my $self = shift;
    my $from = shift;
    my $code = shift;

    $self->max_match_level($from, sub { $code->(@_) ? 'q' : undef });
}

=head2 max_match_level Tile, Code -> Tile, Str

This takes a starting tile and a code reference, and does a breadth-first
search to the first tile that makes the code ref return the maximum value. It
then returns the matching tile and the path to it from the starting tile. If
your coderef returns the string 'q' then the given tile and path will be
returned.

WARNING: Only the level of the starting tile will be searched.

=cut

sub max_match_level {
    my $self = shift;
    my $from = shift;
    my $code = shift;

    my $debug = $main::taeb->config->contents->{debug_bfs};
    my $level = $from->level;

    my $max_score;
    my $max_tile;
    my $max_path;

    my @open = [$from, ''];
    my @closed;

    # randomize the delta array so doors don't kill us
    my @deltas = shuffle (
        [-1, -1], [-1, 0], [-1, 1],
        [ 0, -1], [ 0, 0], [ 0, 1],
        [ 1, -1], [ 1, 0], [ 1, 1],
    );

    while (@open) {
        my ($tile, $path) = @{ shift @open };
        my ($x, $y) = ($tile->x, $tile->y);

        my $score = $code->($tile, $path);
        if (defined($score) && $score eq 'q') {
            print $main::taeb->redraw if $debug;
            return ($tile, $path);
        }

        # if the coderef returns undef, then we don't want to update
        if (defined($score) && (!defined($max_score) || $score > $max_score)) {
            ($max_score, $max_tile, $max_path) = ($score, $tile, $path);
        }

        $closed[$x][$y] = 1;

        for (@deltas) {
            my ($dx, $dy) = @$_;
            next if $closed[$x + $dx][$y + $dy];

            # can't move diagonally off of doors
            next if $tile->type eq 'door'
                    && $dx && $dy;

            my $next = $level->at($x + $dx, $y + $dy);

            # can't move diagonally onto doors
            next if $next->type eq 'door'
                    && $dx && $dy;

            my $dir = direction($dx+1, $dy+1);

            if ($next->is_walkable) {
                push @open, [ $next, $path . $dir ];
                printf "\e[%d;%dH\e[1;34m%s", $y+1+$dy, $x+1+$dx, $next->glyph
                    if $debug;
            }
        }
    }

    print $main::taeb->redraw if $debug;

    return ($max_tile, $max_path);
}

1;


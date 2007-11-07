#!/usr/bin/env perl
package TAEB::Path;
use Moose;

has from => (
    is       => 'ro',
    isa      => 'TAEB::Tile',
    required => 1,
);

has to => (
    is       => 'ro',
    isa      => 'TAEB::Tile',
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

Returns a new TAEB::Path of the path between the tiles. The tiles must be on
the same level.

=cut

sub calculate_intralevel_path {
    my $self = shift;
    my ($from, $to) = @_;
    my ($path, $complete) = $self->_calculate_intralevel_path($from, $to);
    $self->new(from => $from, to => $to, path => $path, complete => $complete);
}

=head2 _calculate_intralevel_path Tile, Tile -> Str, Bool

Actually does the calculation of the path to go from the first tile to the
second. It will return the directions required, and a boolean indicating
whether the path is complete or not. If there is unavoidable unexplored area
between the two tiles, then complete will be false.

=cut

sub _calculate_intralevel_path {
    my $self = shift;
    my ($from, $to) = @_;
    my $path = '';
    my $complete = 0;

    # XXX: todo :)

    return ($path, $complete ? 1 : 0);
}

1;


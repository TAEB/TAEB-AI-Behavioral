#!/usr/bin/env perl
package FOV::NetHack;

use warnings;
use strict;

use Exporter;

our @EXPORT_OK = qw(calculate_fov);
our @ISA = qw(Exporter);

# not handled: swimming, phasing
# possibly buggy: everything
sub calculate_fov {
    my ($startx, $starty, $cb, $cbo) = @_;

    my @visible;

    $cbo ||= sub { my ($x, $y) = @_; $visible[$x][$y] = 1; };

    $cbo->($startx, $starty);

    for my $octant (0 .. 7) {
        my $maj_dx = (1, 0, 0, -1, -1, 0, 0, 1)[$octant];
        my $maj_dy = (0, -1, -1, 0, 0, 1, 1, 0)[$octant];
        my $min_dx = (0, 1, -1, 0, 0, -1, 1, 0)[$octant];
        my $min_dy = (-1, 0, 0, -1, 1, 0, 0, 1)[$octant];

        my $shadowcaster;
        $shadowcaster = sub {
            my ($dist, $min_slope, $max_slope) = @_;

            my $min_minor = int($min_slope * $dist + 0.5);
            my $max_minor = int($max_slope * $dist + 0.5);

            my $last_clear = 0;
            my $window_start = $min_minor;

            for my $minor ($min_minor .. $max_minor) {
                my $start = ($minor - 0.5) / $dist;
                my $end   = ($minor + 0.5) / $dist;

                $start = $min_slope if $start < $min_slope;
                $end   = $max_slope if $end   > $max_slope;

                my $x = $startx + $maj_dx * $dist + $min_dx * $minor;
                my $y = $starty + $maj_dy * $dist + $min_dy * $minor;

                $cbo->($x,$y);

                if ($cb->($x,$y) xor $last_clear) {
                    if ($last_clear) {
                        $last_clear = 0;
                        $shadowcaster->($dist+1, $window_start, $start);
                    } else {
                        $last_clear = 1;
                        $window_start = $start;
                    }
                }
            }

            if ($last_clear) {
                $shadowcaster->($dist+1, $window_start, $max_slope)
            }
        };

        $shadowcaster->(1, 0, 1);
    }

    return \@visible;
}

1;

=head1 NAME

FOV::NetHack - NetHack compatible field of view

=head1 SYNOPSIS

  use FOV::NetHack 'calculate_fov';

  my $AoA = calculate_fov($x, $y, \&transparent);

=head1 DESCRIPTION

This package implements field of view (the determination, for every
square on the map simultaneously, of whether it is visible to the
avatar), in a NetHack compatible way.  It is expected to be primarily
useful to bot writers.

=head1 FUNCTION

FOV::NetHack defines and allows import of a single function.

=over 4

=item B<calculate_fov STARTX, STARTY, INCALLBACK, [OUTCALLBACK]>

STARTX and STARTY determine the location of the avatar on the integer
plane used by FOV::NetHack.  INCALLBACK is used to determine the map's
local structure; it is passed two arguments, X and Y coordinates, and
must return true iff the specified point is transparent.  OUTCALLBACK
is used to return the viewable map, one coordinate pair at a time as
for INCALLBACK.  OUTCALLBACK is optional; if you omit it, calculate_fov
will return an array of arrays such that $ret[$x][$y] will be true
iff ($x,$y) is visible.

Two obligations exist upon the user.  First, there must be no lines of
sight of infinite length.  Second, if OUTCALLBACK is omitted, no tile
with either coordinate negative may be visible.  This stems from the
limitation of array indexes to positive values.  Of course one can also
use $[ to allow negative indexes, but you wouldn't do something like
that, would you?

You may be wondering why the callbacks exist at all and calculate_fov
doesn't just use arrays of arrays both ways.  The answer is asymptotic
complexity.  The algorithm used by calculate_fov takes time proportional
to the number of I<visible> tiles.  If an array of arrays had to be
constructed for the transparency data, any user would suffer time costs
proportional to the number of I<total> tiles.

=back

=head1 AUTHOR

Stefan O'Rear <stefanor@cox.net>

=head1 COPYRIGHT

Copyright (c) 2008 Stefan O'Rear.  All rights reserved.  This
program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=cut


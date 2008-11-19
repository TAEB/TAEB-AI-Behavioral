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


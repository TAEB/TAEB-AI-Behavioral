#!/usr/bin/env perl
package TAEB::Util;
use strict;
use warnings;

use Hash::Inflator;
use List::Util 'first';
use List::MoreUtils 'uniq';

our %colors;

BEGIN {
    %colors = (
        COLOR_BLACK          => 0,
        COLOR_RED            => 1,
        COLOR_GREEN          => 2,
        COLOR_BROWN          => 3,
        COLOR_BLUE           => 4,
        COLOR_MAGENTA        => 5,
        COLOR_CYAN           => 6,
        COLOR_GRAY           => 7,
        COLOR_NONE           => 8,
        COLOR_ORANGE         => 9,
        COLOR_BRIGHT_GREEN   => 10,
        COLOR_YELLOW         => 11,
        COLOR_BRIGHT_BLUE    => 12,
        COLOR_BRIGHT_MAGENTA => 13,
        COLOR_BRIGHT_CYAN    => 14,
        COLOR_WHITE          => 15,
    );
}

use constant \%colors;

use Sub::Exporter -setup => {
    exports => [qw(tile_types glyph_to_type delta2vi vi2delta deltas), keys %colors],
    groups => {
        colors => [keys %colors],
    },
};

our %glyphs = (
    ' '  => 'rock',
    ']'  => 'closeddoor',
    '>'  => 'stairs',
    '<'  => 'stairs',
    '^'  => 'trap',
    '_'  => 'altar',
    '~'  => 'water',

    '|'  => [qw/opendoor wall/],
    '-'  => [qw/opendoor wall/],
    '.'  => [qw/floor ice/],
    '\\' => [qw/grave throne/],
    '{'  => [qw/sink fountain/],
    '}'  => [qw/bars tree drawbridge lava underwater/],

    '#'  => 'corridor',
    #'#'  => 'air', # who cares, no difference
);

# except for traps
# miss =>? deal with it
# traps are a bit hairy. with some remapping magic could rectify..
our %feature_colors = (
    COLOR_BLUE,    [qw/fountain trap water underwater/],
    COLOR_BROWN,   [qw/opendoor closeddoor drawbridge stairs trap/],
    COLOR_CYAN,    [qw/bars ice trap/],
    COLOR_GRAY,    [qw/altar corridor floor grave sink stairs trap wall/],
    COLOR_GREEN,   'tree',
    COLOR_MAGENTA, 'trap',
    COLOR_ORANGE,  'trap',
    COLOR_RED,     [qw/lava trap/],
    COLOR_YELLOW,  'throne',
    COLOR_BRIGHT_BLUE,    'trap',
    COLOR_BRIGHT_GREEN,   'trap',
    COLOR_BRIGHT_MAGENTA, 'trap',
);

our @glyphs = uniq 'obscured', map { ref $_ ? @$_ : $_ } values %glyphs;

sub tile_types {
    return @glyphs;
}

sub glyph_to_type {
    my $glyph = shift;

    return $glyphs{$glyph} || 'obscured' unless @_;

    # use color in an effort to differentiate tiles
    my $color = shift;

    return 'obscured' unless $glyphs{$glyph} && $feature_colors{$color};

    my @a = map { ref $_ ? @$_ : $_ } $glyphs{$glyph};
    my @b = map { ref $_ ? @$_ : $_ } $feature_colors{$color};

    # calculate intersection of the two lists
    # because of the config chosen, given a valid glyph+color combo
    # we are guaranteed to only have one result
    # an invalid combination should not return any
    my %intersect;
    $intersect{$_} |= 1 for @a;
    $intersect{$_} |= 2 for @b;

   my $type = first { $intersect{$_} == 3 } keys %intersect;
   return $type || 'obscured';
}

our @directions = (
    [qw/y k u/],
    [qw/h . l/],
    [qw/b j n/],
);

=head2 delta2vi Int, Int -> Str

This will return a vi key for the given dx, dy.

=cut

sub delta2vi {
    my $dx = shift;
    my $dy = shift;
    return $directions[$dy+1][$dx+1];
}

=head2 vi2delta Str -> Int, Int

This will return a dx, dy key for the given vi key (also accepted is C<.>).

=cut

my %vi2delta = (
    '.' => [ 0,  0],
     h  => [-1,  0],
     j  => [ 0,  1],
     k  => [ 0, -1],
     l  => [ 1,  0],
     y  => [-1, -1],
     u  => [ 1, -1],
     b  => [-1,  1],
     n  => [ 1,  1],
);

sub vi2delta {
    return @{ $vi2delta{ lc $_[0] } || [] };
}

sub deltas {
    # northwest northeast southwest southeast
    # north south west east
    return (
        [-1, -1], [-1,  1], [ 1, -1], [ 1,  1],
        [-1,  0], [ 1,  0], [ 0, -1], [ 0,  1],
    );

}

1;


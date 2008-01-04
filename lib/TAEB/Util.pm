#!/usr/bin/env perl
package TAEB::Util;
use strict;
use warnings;

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
    exports => [qw(tile_types glyph_to_type direction), keys %colors],
    groups => {
        colors => [keys %colors],
    },
};

use List::MoreUtils 'uniq';

our %glyphs = (
    ' '  => 'rock',
    ']'  => 'door',
    '>'  => 'stairs',
    '<'  => 'stairs',
    '^'  => 'trap',
    '_'  => 'altar',
    '~'  => 'water',

    '|'  => [qw/door wall/],
    '-'  => [qw/door wall/],
    '.'  => [qw/floor ice/],
    '\\' => [qw/grave throne/],
    '{'  => [qw/sink fountain/],
    '}'  => [qw/bars tree drawbridge lava underwater/],

    '#'  => 'corridor',
    #'#'  => 'air', # who cares, no difference
);

# except for traps
# miss =>? deal with it
our %feature_colors = (
    COLOR_RED,    'lava',
    COLOR_GREEN,  'tree',
    COLOR_BROWN,  [qw/door drawbridge/],
    COLOR_BLUE,   [qw/fountain water underwater/],
    COLOR_CYAN,   [qw/bars ice/],
    COLOR_GRAY,   [qw/altar corridor floor grave sink stairs wall/],
    COLOR_YELLOW, 'throne',
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
    my @a = map { ref $_ ? @$_ : $_ } $glyphs{$glyph};
    my @b = map { ref $_ ? @$_ : $_ } $feature_colors{$color};

    # calculate intersection of the two lists
    # because of the config chosen, given a valid glyph+color combo
    # we are guaranteed to only have one result
    # an invalid combination should not return any
    my %intersect;
    $intersect{$_} |= 1 for @a;
    $intersect{$_} |= 2 for @b;

    return grep { $intersect{$_} == 3 } keys %intersect;
}

our @directions = (
    [qw/y k u/],
    [qw/h . l/],
    [qw/b j n/],
);

sub direction {
    my $x = shift;
    my $y = shift;
    return $directions[$y][$x];
}

1;


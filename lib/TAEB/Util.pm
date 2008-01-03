#!/usr/bin/env perl
package TAEB::Util;
use strict;
use warnings;
use Sub::Exporter -setup => {
    exports => [qw(tile_types glyph_to_type direction)],
};

use List::MoreUtils 'uniq';

use constant {
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
    COLOR_MAX            => 16,
};

our %glyphs = (
    ' '  => 'rock',
    '|'  => 'wall',
    '-'  => 'wall',
    '.'  => 'floor',
    ']'  => 'door',
    ','  => 'door',
    '>'  => 'stairs',
    '<'  => 'stairs',
    '^'  => 'trap',
    '_'  => 'altar',
    '\\' => 'throne',

    '{'  => [qw/sink fountain grave/],
    '}'  => [qw/bars tree drawbridge water lava underwater/],

    '#'  => 'corridor',
    #'#'  => 'air', # who cares, no difference
);

our @glyphs = uniq 'obscured', map { ref $_ ? @$_ : $_ } values %glyphs;

sub tile_types {
    return @glyphs;
}

sub glyph_to_type {
    my $glyph = shift;
    return $glyphs{$glyph} || 'obscured';
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


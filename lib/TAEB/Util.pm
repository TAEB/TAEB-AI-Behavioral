#!/usr/bin/env perl
package TAEB::Util;
use strict;
use warnings;
use Sub::Exporter -setup => {
    exports => [qw(tile_types glyph_to_type direction)],
};

use List::MoreUtils 'uniq';

our %glyphs = (
    ' '  => 'obscured',
    '|'  => 'wall',
    '-'  => 'wall',
    '.'  => 'floor',
    ']'  => 'door',
    ','  => 'door',
    '>'  => 'stairs',
    '<'  => 'stairs',
    '^'  => 'trap',
    '\\' => 'throne',

    '_'  => [qw/grave altar/],
    '{'  => [qw/sink fountain/],
    '}'  => [qw/bars tree drawbridge water lava underwater/],

    '#'  => 'corridor',
    #'#'  => 'air', # who cares, no difference
);

our @glyphs = uniq map { ref $_ ? @$_ : $_ } values %glyphs;

sub tile_types {
    return @glyphs;
}

sub glyph_to_type {
    my $glyph = shift;
    return $glyphs{$glyph};
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


#!/usr/bin/env perl
package TAEB::Util;
use strict;
use warnings;
use Sub::Exporter -setup => {
    exports => qw(tile_types glyph_to_type),
};

use List::Utils 'uniq';

our %glyphs = (
    "\0" => 'obscured',
    ' '  => 'rock',
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

1;


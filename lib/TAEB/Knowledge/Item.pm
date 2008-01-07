#!/usr/bin/env perl
package TAEB::Knowledge::Item;
use strict;
use warnings;

use TAEB::Knowledge::Item::Food;
use TAEB::Knowledge::Item::Weapon;
use TAEB::Knowledge::Item::Tool;
use TAEB::Knowledge::Item::Artifact;

sub canonicalize_item {
    my $self = shift;
    my $item = shift;

    my @words = qw(the an a greased blessed cursed uncursed);
    my @regex = (
        qr/[+-]?\d+/,               # enchantment, quantity
        qr/\b(?:fire|rust)proof\b/,
        qr/\([^)]+\)/,              # (being warn), (lit), etc
    );

    $item =~ s/\b$_\b//ig for @words;
    $item =~ s/$_//g      for @regex;

    # extra space bad
    $item =~ s/\s+/ /g;
    $item =~ s/^ //;
    $item =~ s/ $//;

    return $item;
}

1;


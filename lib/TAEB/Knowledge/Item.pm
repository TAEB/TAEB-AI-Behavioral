#!/usr/bin/env perl
package TAEB::Knowledge::Item;
use strict;
use warnings;

use TAEB::Knowledge::Item::Food;
use TAEB::Knowledge::Item::Weapon;
use TAEB::Knowledge::Item::Tool;
use TAEB::Knowledge::Item::Artifact;
use TAEB::Knowledge::Item::Armor;

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

    # try to turn plurals into singular
    $item =~ s/s$//;

    return $item;
}

1;


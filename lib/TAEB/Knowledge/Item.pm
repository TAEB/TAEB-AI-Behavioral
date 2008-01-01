#!/usr/bin/env perl
package TAEB::Knowledge::Item;
use strict;
use warnings;

use TAEB::Knowledge::Item::Food;
use TAEB::Knowledge::Item::Weapon;

sub canonicalize_item {
    my $self = shift;
    my $item = shift;

    my @words = qw(the an a greased blessed cursed uncursed);
    my @regex = (
        qr/[+-]?\d+/, # enchantment, quantity
        qr/\b(?:fire|rust)proof\b/,
    );

    $item =~ s/\b$_\b//ig for @words;
    $item =~ s/$_//g      for @regex;

    $item =~ s/\s+/ /g;

    return $item;
}

1;


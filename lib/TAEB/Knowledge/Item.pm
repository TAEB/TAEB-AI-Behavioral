#!/usr/bin/env perl
package TAEB::Knowledge::Item;
use strict;
use warnings;

use TAEB::Knowledge::Item::Food;
use TAEB::Knowledge::Item::Weapon;
use TAEB::Knowledge::Item::Tool;
use TAEB::Knowledge::Item::Artifact;
use TAEB::Knowledge::Item::Armor;

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $items = {};

        for (qw/Weapon Armor Tool Food/) {
            my $list = "TAEB::Knowledge::Item::$_"->list;
            while (my ($name, $stats) = each %$list) {
                $items->{$name} = lc $_;
                $items->{$stats->{appearance}} = lc $_;
            }
        }

        return $items;
    },
);

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


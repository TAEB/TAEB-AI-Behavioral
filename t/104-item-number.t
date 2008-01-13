#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["a - a +1 long sword (weapon in hand)", {quantity => 1} ],
    ["A - an uncursed +0 orcish ring mail",  {quantity => 1} ],
    ["k - the Eye of the Aethiopica",        {quantity => 1} ],
    ["j - 2 slime molds",                    {quantity => 2} ],
    ["m - 23 uncursed rocks",                {quantity => 23}],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;

for my $test (@tests) {
    my ($appearance, $expected) = @$test;
    my $item = TAEB::World::Item->new_item($appearance);
    while (my ($attr, $attr_expected) = each %$expected) {
        is($item->$attr, $attr_expected, "parsed $attr of $appearance");
    }
}


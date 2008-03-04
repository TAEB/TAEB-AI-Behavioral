#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;
use TAEB::Test;

my @tests = (
    ["a - a +1 long sword (weapon in hand)", {quantity => 1} ],
    ["A - an uncursed +0 orcish ring mail",  {quantity => 1} ],
    ["k - the Eye of the Aethiopica",        {quantity => 1} ],
    ["j - 2 slime molds",                    {quantity => 2} ],
    ["m - 23 uncursed rocks",                {quantity => 23}],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;
test_items(@tests);

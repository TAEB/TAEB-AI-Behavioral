#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;
use TAEB::Test;

my @tests = (
    ["a - a +1 long sword (weapon in hand)",           {enchantment => 1}  ],
    ["f - the +0 Cleaver",                             {enchantment => 0}  ],
    ["m - a blessed +4 long sword",                    {enchantment => 4}  ],
    ["E - a blessed poisoned rusty corroded -1 arrow", {enchantment => -1} ],
    ["h - the uncursed +10 Mitre of Holiness",         {enchantment => 10} ],
    ["p - a -10 unicorn horn",                         {enchantment => -10}],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;
test_items(@tests);

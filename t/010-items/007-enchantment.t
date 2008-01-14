#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["a - a +1 long sword (weapon in hand)",           {enchantment => 1}  ],
    ["f - the +0 Cleaver",                             {enchantment => 0}  ],
    ["m - a blessed +4 long sword",                    {enchantment => 4}  ],
    ["E - a blessed poisoned rusty corroded -1 arrow", {enchantment => -1} ],
    ["h - the uncursed +10 Mitre of Holiness",         {enchantment => 10} ],
    ["p - a -10 unicorn horn",                         {enchantment => -10}],
    ["S - an uncursed +1 ring of protection",          {enchantment => 1}  ],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;

for my $test (@tests) {
    my ($appearance, $expected) = @$test;
    my $item = TAEB::World::Item->new_item($appearance);
    while (my ($attr, $attr_expected) = each %$expected) {
        if (defined $item) {
            is($item->$attr, $attr_expected, "parsed $attr of $appearance");
        }
        else {
            fail("parsed $attr of $appearance");
            diag("$appearance produced an undef item object");
        }
    }
}

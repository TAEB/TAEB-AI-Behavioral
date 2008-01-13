#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["a - a +1 long sword (weapon in hand)",  {buc => 'uncursed'}],
    ["i - a blessed potion of enlightenment", {buc => 'blessed'} ],
    ["j - a cursed skeleton key",             {buc => 'cursed'}  ],
    ["k - a scroll labeled THARR",            {buc => 'unknown'} ],
    ["l - a pick-axe",                        {buc => 'unknown'} ],
    ["l - a +0 pick-axe",                     {buc => 'uncursed'}],
    ["m - a long sword",                      {buc => 'unknown'} ],
    ["m - a blessed +4 long sword",           {buc => 'blessed'} ],
    ["m - a +4 long sword",                   {buc => 'uncursed'}],
    ["n - a clear potion",                    {buc => 'unknown'} ],
    ["n - a potion of holy water",            {buc => 'blessed'} ],
    ["o - a potion of unholy water",          {buc => 'cursed'}  ],
    ["p - a unicorn horn",                    {buc => 'unknown'} ],
    ["p - a +2 unicorn horn",                 {buc => 'uncursed'}],
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

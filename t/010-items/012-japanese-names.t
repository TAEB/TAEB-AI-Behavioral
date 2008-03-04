#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["b - a wakizashi",      {identity => "short sword"}    ],
    ["f - a ninja-to",       {identity => "broadsword"}     ],
    ["g - a nunchaku",       {identity => "flail"}          ],
    ["h - a naginata",       {identity => "glaive"}         ],
    ["i - an osaku",         {identity => "lock pick"}      ],
    ["k - a koto",           {identity => "wooden harp"}    ],
    ["l - a shito",          {identity => "knife"}          ],
    ["m - a tanko",          {identity => "plate mail"}     ],
    ["n - a kabuto",         {identity => "helmet"}         ],
    ["o - a pair of yugake", {identity => "leather gloves"} ],
    ["p - a gunyoki",        {identity => "food ration"}    ],
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

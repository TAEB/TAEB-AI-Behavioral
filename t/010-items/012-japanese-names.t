#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;
use TAEB::Test;

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
test_items(@tests);

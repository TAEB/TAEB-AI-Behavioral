#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["x - 100 gold pieces",                             {class => "gold"}     ],
    ["a - a +1 long sword (weapon in hand)",            {class => "weapon"}   ],
    ["b - a blessed +0 dagger",                         {class => "weapon"}   ],
    ["h - 8 +0 darts",                                  {class => "weapon"}   ],
    ["s - a poisoned +0 arrow",                         {class => "weapon"}   ],
    ["p - a +0 boomerang",                              {class => "weapon"}   ],
    ["S - the +0 Cleaver",                              {class => "weapon"}   ],
    ["c - an uncursed +3 small shield (being worn)",    {class => "armor"}    ],
    ["o - an uncursed +0 banded mail",                  {class => "armor"}    ],
    ["q - an uncursed +0 crystal plate mail",           {class => "armor"}    ],
    ["h - the uncursed +0 Mitre of Holiness",           {class => "armor"}    ],
    ["r - a blessed +0 pair of speed boots",            {class => "armor"}    ],
    ["t - a set of gray dragon scales",                 {class => "armor"}    ],
    ["d - 2 uncursed food rations",                     {class => "food"}     ],
    ["j - a cursed tin of lichen",                      {class => "food"}     ],
    ["K - an uncursed tin of newt meat",                {class => "food"}     ],
    ["r - an uncursed partly eaten tripe ration",       {class => "food"}     ],
    ["P - a blessed lichen corpse",                     {class => "food"}     ],
    ["R - an uncursed guardian naga egg",               {class => "food"}     ],
    ["w - an uncursed empty tin",                       {class => "food"}     ],
    ["M - a cursed scroll of light",                    {class => "scroll"}   ],
    ["N - an uncursed scroll of identify",              {class => "scroll"}   ],
    ["O - a blessed scroll of earth",                   {class => "scroll"}   ],
    ["k - an uncursed spellbook of cure sickness",      {class => "spellbook"}],
    ["m - an uncursed spellbook of detect unseen",      {class => "spellbook"}],
    ["T - the uncursed Book of the Dead",               {class => "spellbook"}],
    ["C - an uncursed potion of restore ability",       {class => "potion"}   ],
    ["Q - an uncursed diluted potion of speed",         {class => "potion"}   ],
    ["R - a blessed potion of full healing",            {class => "potion"}   ],
    ["i - an uncursed amulet of ESP",                   {class => "amulet"}   ],
    ["l - a cursed amulet of restful sleep",            {class => "amulet"}   ],
    ["z - an uncursed amulet versus poison",            {class => "amulet"}   ],
    ["k - the Eye of the Aethiopica",                   {class => "amulet"}   ],
    ["U - the Amulet of Yendor",                        {class => "amulet"}   ],
    ["G - an uncursed ring of conflict",                {class => "ring"}     ],
    ["S - a cursed -1 ring of protection",              {class => "ring"}     ],
    ["T - a cursed ring of see invisible",              {class => "ring"}     ],
    ["B - a wand of fire (0:8)",                        {class => "wand"}     ],
    ["U - a wand of speed monster (0:8)",               {class => "wand"}     ],
    ["V - a wand of sleep (0:5)",                       {class => "wand"}     ],
    ["e - a +0 pick-axe",                               {class => "tool"}     ],
    ["f - a +0 grappling hook",                         {class => "tool"}     ],
    ["t - an uncursed large box",                       {class => "tool"}     ],
    ["W - a blessed magic lamp (lit)",                  {class => "tool"}     ],
    ["m - the Master Key of Thievery",                  {class => "tool"}     ],
    ["G - a cursed partly used wax candle (lit)",       {class => "tool"}     ],
    ["u - a figurine of a lichen",                      {class => "tool"}     ],
    ["n - an uncursed worthless piece of orange glass", {class => "gem"}      ],
    ["Y - an uncursed dilithium crystal",               {class => "gem"}      ],
    ["u - 53 rocks",                                    {class => "gem"}      ],
    ["n - the Heart of Ahriman",                        {class => "gem"}      ],
    ["v - a statue of a lichen",                        {class => "statue"}   ],
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

#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["x - a samurai sword",                              {class => "weapon"}],
    ["y - a crude dagger",                               {class => "weapon"}],
    ["z - a broad pick",                                 {class => "weapon"}],
    ["f - a double-headed axe named Cleaver",            {class => "weapon"}],
    ["A - a crude ring mail",                            {class => "armor"} ],
    ["B - an apron",                                     {class => "armor"} ],
    ["C - a faded pall",                                 {class => "armor"} ],
    ["h - a visored helmet named The Mitre of Holiness", {class => "armor"} ],
    ["i - an egg",                                       {class => "food"}  ],
    ["D - a tin",                                        {class => "food"}  ],
    ["f - a scroll labeled PRATYAVAYAH",                 {class => "scroll"}],
    ["m - a scroll labeled JUYED AWK YACC",              {class => "scroll"}],
    ["E - a scroll labeled FOOBIE BLETCH",               {class => "scroll"}],
    ["l - an orange spellbook",                          {class => "book"}  ],
    ["n - a light blue spellbook",                       {class => "book"}  ],
    ["u - a magenta spellbook",                          {class => "book"}  ],
    ["g - a papyrus spellbook",                          {class => "book"}  ],
    ["N - a murky potion",                               {class => "potion"}],
    ["O - a sky blue potion",                            {class => "potion"}],
    ["P - a brown potion",                               {class => "potion"}],
    ["h - a hexagonal amulet",                           {class => "amulet"}],
    ["G - a triangular amulet",                          {class => "amulet"}],
    ["H - a pyramidal amulet",                           {class => "amulet"}],
    ["q - a gold ring",                                  {class => "ring"}  ],
    ["t - a granite ring",                               {class => "ring"}  ],
    ["v - an opal ring",                                 {class => "ring"}  ],
    ["K - a runed wand",                                 {class => "wand"}  ],
    ["L - a brass wand",                                 {class => "wand"}  ],
    ["M - an oak wand",                                  {class => "wand"}  ],
    ["g - 2 yellow gems",                                {class => "gem"}   ],
    ["I - a green gem",                                  {class => "gem"}   ],
    ["Q - a gray stone",                                 {class => "gem"}   ],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;

for my $test (@tests) {
    my ($appearance, $expected) = @$test;
    my $item = TAEB::World::Item->new(appearance => $appearance);
    while (my ($attr, $attr_expected) = each %$expected) {
        is($item->$attr, $attr_expected, "parsed $attr of $appearance");
    }
}

#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["x - a samurai sword",
     {visible_description => "samurai sword"}],
    ["y - a crude dagger",
     {visible_description => "crude dagger"}],
    ["z - a broad pick",
     {visible_description => "broad pick"}],
    ["f - a double-headed axe named Cleaver",
     {visible_description => "double-headed axe"}],
    ["A - a crude ring mail",
     {visible_description => "crude ring mail"}],
    ["B - an apron",
     {visible_description => "apron"}],
    ["C - a faded pall",
     {visible_description => "faded pall"}],
    ["h - a visored helmet named The Mitre of Holiness",
     {visible_description => "visored helmet"}],
    ["s - a pair of riding gloves",
     {visible_description => "riding gloves"}],
    ["i - an egg",
     {visible_description => "egg"}],
    ["D - a tin",
     {visible_description => "tin"}],
    ["f - a scroll labeled PRATYAVAYAH",
     {visible_description => "scroll labeled PRATYAVAYAH"}],
    ["m - a scroll labeled JUYED AWK YACC",
     {visible_description => "scroll labeled JUYED AWK YACC"}],
    ["E - a scroll labeled FOOBIE BLETCH",
     {visible_description => "scroll labeled FOOBIE BLETCH"}],
    ["l - an orange spellbook",
     {visible_description => "orange spellbook"}],
    ["n - a light blue spellbook",
     {visible_description => "light blue spellbook"}],
    ["u - a magenta spellbook",
     {visible_description => "magenta spellbook"}],
    ["g - a papyrus spellbook",
     {visible_description => "papyrus spellbook"}],
    ["N - a murky potion",
     {visible_description => "murky potion"}],
    ["O - a sky blue potion",
     {visible_description => "sky blue potion"}],
    ["P - a brown potion",
     {visible_description => "brown potion"}],
    ["h - a hexagonal amulet",
     {visible_description => "hexagonal amulet"}],
    ["G - a triangular amulet",
     {visible_description => "triangular amulet"}],
    ["H - a pyramidal amulet",
     {visible_description => "pyramidal amulet"}],
    ["q - a gold ring",
     {visible_description => "gold ring"}],
    ["t - a granite ring",
     {visible_description => "granite ring"}],
    ["v - an opal ring",
     {visible_description => "opal ring"}],
    ["K - a runed wand",
     {visible_description => "runed wand"}],
    ["L - a brass wand",
     {visible_description => "brass wand"}],
    ["M - an oak wand",
     {visible_description => "oak wand"}],
    ["g - 2 yellow gems",
     {visible_description => "yellow gem"}],
    ["I - a green gem",
     {visible_description => "green gem"}],
    ["Q - a gray stone",
     {visible_description => "gray stone"}],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;

for my $test (@tests) {
    my ($appearance, $expected) = @$test;
    my $item = TAEB::World::Item->new(appearance => $appearance);
    while (my ($attr, $attr_expected) = each %$expected) {
        is($item->$attr, $attr_expected, "parsed $attr of $appearance");
    }
}

#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["x - a samurai sword",
     {identity => "samurai sword"}],
    ["y - a crude dagger",
     {identity => "crude dagger"}],
    ["z - a broad pick",
     {identity => "broad pick"}],
    ["f - a double-headed axe named Cleaver",
     {identity => "double-headed axe"}],
    ["A - a crude ring mail",
     {identity => "crude ring mail"}],
    ["B - an apron",
     {identity => "apron"}],
    ["C - a faded pall",
     {identity => "faded pall"}],
    ["h - a visored helmet named The Mitre of Holiness",
     {identity => "visored helmet"}],
    ["s - a pair of riding gloves",
     {identity => "riding gloves"}],
    ["i - an egg",
     {identity => "egg"}],
    ["D - a tin",
     {identity => "tin"}],
    ["f - a scroll labeled PRATYAVAYAH",
     {identity => "scroll labeled PRATYAVAYAH"}],
    ["m - a scroll labeled JUYED AWK YACC",
     {identity => "scroll labeled JUYED AWK YACC"}],
    ["E - a scroll labeled FOOBIE BLETCH",
     {identity => "scroll labeled FOOBIE BLETCH"}],
    ["l - an orange spellbook",
     {identity => "orange spellbook"}],
    ["n - a light blue spellbook",
     {identity => "light blue spellbook"}],
    ["u - a magenta spellbook",
     {identity => "magenta spellbook"}],
    ["g - a papyrus spellbook",
     {identity => "papyrus spellbook"}],
    ["N - a murky potion",
     {identity => "murky potion"}],
    ["O - a sky blue potion",
     {identity => "sky blue potion"}],
    ["P - a brown potion",
     {identity => "brown potion"}],
    ["h - a hexagonal amulet",
     {identity => "hexagonal amulet"}],
    ["G - a triangular amulet",
     {identity => "triangular amulet"}],
    ["H - a pyramidal amulet",
     {identity => "pyramidal amulet"}],
    ["q - a gold ring",
     {identity => "gold ring"}],
    ["t - a granite ring",
     {identity => "granite ring"}],
    ["v - an opal ring",
     {identity => "opal ring"}],
    ["K - a runed wand",
     {identity => "runed wand"}],
    ["L - a brass wand",
     {identity => "brass wand"}],
    ["M - an oak wand",
     {identity => "oak wand"}],
    ["g - 2 yellow gems",
     {identity => "yellow gem"}],
    ["I - a green gem",
     {identity => "green gem"}],
    ["Q - a gray stone",
     {identity => "gray stone"}],
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

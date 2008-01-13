#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["a - a +1 long sword (weapon in hand)",
     {generic_name => "", specific_name => ""}],
    ["f - a pair of fencing gloves named x",
     {generic_name => "", specific_name => "x"}],
    ["f - a pair of gloves called y named x",
     {generic_name => "y", specific_name => "x"}],
    ["i - a spellbook called x y z",
     {generic_name => "x y z", specific_name => ""}],
    ["h - a sky blue potion named z y x",
     {generic_name => "", specific_name => "z y x"}],
    ["c - 16 uncursed flint stones named x (in quiver)",
     {generic_name => "", specific_name => "x"}],
    ["f - a pair of gloves called y named x (weapon in hand)",
     {generic_name => "y", specific_name => "x"}],
    ["i - a spellbook called x y z (weapon in hand)",
     {generic_name => "x y z", specific_name => ""}],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;

for my $test (@tests) {
    my ($appearance, $expected) = @$test;
    my $item = TAEB::World::Item->new_item($appearance);
    while (my ($attr, $attr_expected) = each %$expected) {
        is($item->$attr, $attr_expected, "parsed $attr of $appearance");
    }
}

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
    ["h - a sky blue potion named z y x",
     {generic_name => "", specific_name => "z y x"}],
    ["c - 16 uncursed flint stones named x (in quiver)",
     {generic_name => "", specific_name => "x"}],
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

#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["a - a blessed +1 quarterstaff (weapon in hands) (unpaid, 15 zorkmids)",
     {cost => 15}],
    ["p - a +0 studded leather armor (being worn) (unpaid, 15 zorkmids)",
     {cost => 15}],
    ["x - 11 arrows (in quiver) (unpaid, 22 zorkmids)",
     {cost => 22}],
    ["B - a tin (unpaid, 5 zorkmids)",
     {cost => 5}],
    ["o - an uncursed amulet of reflection (being worn) (unpaid, 150 zorkmids)",
     {cost => 150}],
    ["d - an uncursed ring of warning (on right hand) (unpaid, 100 zorkmids)",
     {cost => 100}],
    ["c - a wand of create monster (0:12) (unpaid, 200 zorkmids)",
     {cost => 200}],
    ["I - a lamp (lit) (unpaid, 10 zorkmids)",
     {cost => 10}],
    ["z - a yellow gem (unpaid, 1500 zorkmids)",
     {cost => 1500}],
    ["H - a partly used candle",
     {cost => 0}],
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

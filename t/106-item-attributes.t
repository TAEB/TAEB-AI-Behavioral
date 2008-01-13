#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["a - a +1 club",
     {is_greased => 0, is_poisoned => 0, erosion1 => 0, erosion2 => 0,
      is_fooproof => 0, , partly_used => 0}],
    ["m - a blessed +4 long sword",
     {is_greased => 0, is_poisoned => 0, erosion1 => 0, erosion2 => 0,
      is_fooproof => 0, , partly_used => 0}],
    ["s - a poisoned +0 arrow",
     {is_greased => 0, is_poisoned => 1, erosion1 => 0, erosion2 => 0,
      is_fooproof => 0, , partly_used => 0}],
    ["C - a poisoned rusty +0 arrow",
     {is_greased => 0, is_poisoned => 1, erosion1 => 1, erosion2 => 0,
      is_fooproof => 0, , partly_used => 0}],
    ["D - a poisoned very rusty corroded +0 arrow",
     {is_greased => 0, is_poisoned => 1, erosion1 => 2, erosion2 => 1,
      is_fooproof => 0, , partly_used => 0}],
    ["E - a blessed poisoned rusty thoroughly corroded +1 arrow",
     {is_greased => 0, is_poisoned => 1, erosion1 => 1, erosion2 => 3,
      is_fooproof => 0, , partly_used => 0}],
    ["F - a blessed greased poisoned rusty corroded +2 arrow",
     {is_greased => 1, is_poisoned => 1, erosion1 => 1, erosion2 => 1,
      is_fooproof => 0, , partly_used => 0}],
    ["e - an uncursed rotted fireproof +0 leather armor (being worn)",
     {is_greased => 0, is_poisoned => 0, erosion1 => 0, erosion2 => 1,
      is_fooproof => 1, , partly_used => 0}],
    ["t - an uncursed greased partly used tallow candle (lit)",
     {is_greased => 1, is_poisoned => 0, erosion1 => 0, erosion2 => 0,
      is_fooproof => 0, , partly_used => 1}],
    ["v - an uncursed burnt rotted partly used tallow candle",
     {is_greased => 0, is_poisoned => 0, erosion1 => 1, erosion2 => 1,
      is_fooproof => 0, , partly_used => 1}],
    ["f - an uncursed diluted potion of monster detection",
     {is_greased => 0, is_poisoned => 0, erosion1 => 0, erosion2 => 0,
      is_fooproof => 0, , partly_used => 1}],
    ["h - an uncursed partly eaten food ration",
     {is_greased => 0, is_poisoned => 0, erosion1 => 0, erosion2 => 0,
      is_fooproof => 0, , partly_used => 1}],
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

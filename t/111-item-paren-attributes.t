#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["a - a +1 long sword (weapon in hand)",
     {recharges => undef, charges => undef, candles_attached => 0,
      is_lit => 0, is_quivered => 0, is_offhand => 0, is_equipped => 1,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["i - a spellbook called x y z (weapon in hand)",
     {recharges => undef, charges => undef, candles_attached => 0,
      is_lit => 0, is_quivered => 0, is_offhand => 0, is_equipped => 1,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["f - a long sword (alternate weapon; not wielded)",
     {recharges => undef, charges => undef, candles_attached => 0,
      is_lit => 0, is_quivered => 0, is_offhand => 1, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["g - 2 darts (in quiver)",
     {recharges => undef, charges => undef, candles_attached => 0,
      is_lit => 0, is_quivered => 1, is_offhand => 0, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["e - an uncursed oil lamp (lit)",
     {recharges => undef, charges => undef, candles_attached => 0,
      is_lit => 1, is_quivered => 0, is_offhand => 0, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["e - an uncursed oil lamp (lit) (weapon in hand)",
     {recharges => undef, charges => undef, candles_attached => 0,
      is_lit => 1, is_quivered => 0, is_offhand => 0, is_equipped => 1,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["h - a wand of fire (0:6)",
     {recharges => 0, charges => 6, candles_attached => 0,
      is_lit => 0, is_quivered => 0, is_offhand => 0, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["h - a wand of fire (0:6) (alternate weapon; not wielded)",
     {recharges => 0, charges => 6, candles_attached => 0,
      is_lit => 0, is_quivered => 0, is_offhand => 1, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["h - a wand of fire (0:-1)",
     {recharges => 0, charges => -1, candles_attached => 0,
      is_lit => 0, is_quivered => 0, is_offhand => 0, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["i - a wand of cancellation (2:0)",
     {recharges => 2, charges => 0, candles_attached => 0,
      is_lit => 0, is_quivered => 0, is_offhand => 0, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["l - a wand of undead turning (6:11)",
     {recharges => 6, charges => 11, candles_attached => 0,
      is_lit => 0, is_quivered => 0, is_offhand => 0, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["n - a candelabrum (no candles attached)",
     {recharges => undef, charges => undef, candles_attached => 0,
      is_lit => 0, is_quivered => 0, is_offhand => 0, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["n - a candelabrum (1 candle attached)",
     {recharges => undef, charges => undef, candles_attached => 1,
      is_lit => 0, is_quivered => 0, is_offhand => 0, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["n - a candelabrum (1 candle, lit)",
     {recharges => undef, charges => undef, candles_attached => 1,
      is_lit => 1, is_quivered => 0, is_offhand => 0, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["n - a candelabrum (1 candle, lit) (weapon in hand)",
     {recharges => undef, charges => undef, candles_attached => 1,
      is_lit => 1, is_quivered => 0, is_offhand => 0, is_equipped => 1,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["n - a candelabrum (7 candles, lit) (weapon in hand)",
     {recharges => undef, charges => undef, candles_attached => 7,
      is_lit => 1, is_quivered => 0, is_offhand => 0, is_equipped => 1,
      is_laid_by_you => 0, is_chained_to_you => 0}],
    ["j - a cockatrice egg (laid by you) (in quiver)",
     {recharges => undef, charges => undef, candles_attached => 0,
      is_lit => 0, is_quivered => 1, is_offhand => 0, is_equipped => 0,
      is_laid_by_you => 1, is_chained_to_you => 0}],
    ["s - a heavy iron ball (chained to you) (alternate weapon; not wielded)",
     {recharges => undef, charges => undef, candles_attached => 0,
      is_lit => 0, is_quivered => 0, is_offhand => 1, is_equipped => 0,
      is_laid_by_you => 0, is_chained_to_you => 1}],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;

for my $test (@tests) {
    my ($appearance, $expected) = @$test;
    my $item = TAEB::World::Item->new(appearance => $appearance);
    while (my ($attr, $attr_expected) = each %$expected) {
        is($item->$attr, $attr_expected, "parsed $attr of $appearance");
    }
}

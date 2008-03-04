#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;
use TAEB::Test;

my @tests = (
    ["a - a +1 long sword (weapon in hand)", {slot => 'a'}],
    ["B + a blessed +0 alchemy smock",       {slot => 'B'}],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;
test_items(@tests);

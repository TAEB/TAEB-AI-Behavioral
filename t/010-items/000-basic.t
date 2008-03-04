#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;
use TAEB::Test;

my @tests = (
    ["a - a +1 long sword (weapon in hand)", {slot => 'a',
                                              quantity => 1,
                                              enchantment => 1,
                                              identity => 'long sword',
                                              appearance => 'long sword',
                                              class => 'weapon',
                                              is_wielding => 1,
                                              buc => 'uncursed',
                                             }],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;

test_items(@tests);

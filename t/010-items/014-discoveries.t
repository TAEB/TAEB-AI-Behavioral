#!perl -T
use strict;
use warnings;
use TAEB::Test;
use List::Util 'sum';

TAEB::Knowledge->msg_discovery('potion of sickness' => 'effervescent');

my @tests = (
    ["potion of sickness", {
        class      => "potion",
        quantity   => 1,
        buc        => "unknown",
        identity   => "potion of sickness",
        appearance => "effervescent potion",
    }],

);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;
test_items(@tests);

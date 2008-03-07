#!perl -T
use strict;
use warnings;
use TAEB::Test;

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
plan_items(@tests);
test_items(@tests);

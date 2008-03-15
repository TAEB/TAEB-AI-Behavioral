#!perl -T
use strict;
use warnings;
use TAEB::Test;

TAEB->knowledge->msg_discovery('potion of sickness' => 'effervescent');
TAEB->knowledge->msg_discovery('scroll of enchant weapon' => 'KIRJE');

my @tests = (
    ["potion of sickness", {
        class      => "potion",
        quantity   => 1,
        buc        => "unknown",
        identity   => "potion of sickness",
        appearance => "effervescent potion",
    }],
    ["2 scrolls of enchant weapon", {
        class      => "scroll",
        quantity   => 2,
        buc        => "unknown",
        identity   => "scroll of enchant weapon",
        appearance => "scroll labeled KIRJE",
    }],
);
plan_items(@tests);
test_items(@tests);

#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

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


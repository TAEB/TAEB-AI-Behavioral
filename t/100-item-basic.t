#!perl -T
use strict;
use warnings;
use Test::More tests => 7;
use TAEB;

my $item = TAEB::World::Item->new(appearance => "a - a +1 long sword (weapon in hand)");

my %expected = (
    slot => 'a',
    quantity => 1,
    enchantment => 1,
    identity => 'long sword',
    class => 'weapon',
    is_equipped => 1,
    buc => 'uncursed',
);

while (my ($method, $expected) = each %expected) {
    is($item->$method, $expected, "parsed $method");
}

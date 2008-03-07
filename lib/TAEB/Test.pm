#!/usr/bin/perl
package TAEB::Test;
use strict;
use warnings;
use TAEB::World::Item;

=head2 test_items ITEM_LIST

Takes a list of two item arrayrefs, where the first item is a string of the item's description and the second item is a hashref containing property/value pairs for the item. For example,
    test_items(["x - 100 gold pieces",                  {class => "gold"}],
               ["a - a +1 long sword (weapon in hand)", {class => "weapon"}]);

=cut

sub test_items {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    for my $test (@_) {
        my ($appearance, $expected) = @$test;
        my $item = eval { TAEB::World::Item->new_item($appearance) };
        warn $@ if $@;

        while (my ($attr, $attr_expected) = each %$expected) {
            if (defined $item) {
                main::is($item->$attr, $attr_expected,
                         "parsed $attr of $appearance");
            }
            else {
                main::fail("parsed $attr of $appearance");
                main::diag("$appearance produced an undef item object");
            }
        }
    }
}

1;


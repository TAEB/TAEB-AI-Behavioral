#!/usr/bin/perl
package TAEB::Test;
use strict;
use warnings;
use TAEB;
use parent 'Test::More';

our @EXPORT = 'test_items';

sub import_extra {
    Test::More->export_to_level(2);
    strict->import;
    warnings->import;
}

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
                Test::More::is($item->$attr, $attr_expected,
                         "parsed $attr of $appearance");
            }
            else {
                Test::More::fail("parsed $attr of $appearance");
                Test::More::diag("$appearance produced an undef item object");
            }
        }
    }
}

1;


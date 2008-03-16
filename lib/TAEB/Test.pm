#!/usr/bin/perl
package TAEB::Test;
use strict;
use warnings;
use TAEB;
use parent 'Test::More';
use List::Util 'sum';

our @EXPORT = qw/test_items plan_items/;

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
        my $appearance = shift @$test;
        my %expected = @$test == 1 ? %{ $test->[0] } : @$test;

        my $item = eval { TAEB->new_item($appearance) };
        warn $@ if $@;

        while (my ($attr, $attr_expected) = each %expected) {
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

=head2 plan_items ITEM_LIST

This will take the item list and count the number of tests that would be run.
If called in void context, the plan will be set for you. If called in nonvoid
context, the number of item tests will be returned.

=cut

sub plan_items {
    my $tests = sum map {
        ref $_->[1] eq 'HASH'
        ? scalar keys %{ $_->[1] }
        : (@$_ - 1) / 2
    } @_;

    return $tests if defined wantarray;

    Test::More::plan tests => $tests;
}

1;


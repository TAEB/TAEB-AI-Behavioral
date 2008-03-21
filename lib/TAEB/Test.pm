#!/usr/bin/perl
package TAEB::Test;
use strict;
use warnings;
use TAEB;
use parent 'Test::More';
use List::Util 'sum';

our @EXPORT = qw/test_items test_monsters plan_tests/;

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
    test_generic(sub { TAEB->new_item(shift) }, @_);
}

=head2 test_monsters MONSTER_LIST

Identical to test_items in style, except for monsters.

=cut

sub test_monsters {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    test_generic(sub { TAEB->new_monster(shift) }, @_);
}

sub test_generic {
    my $code = shift;
    for my $test (@_) {
        my $name = shift @$test;
        my %expected = @$test == 1 ? %{ $test->[0] } : @$test;

        my $obj = eval { $code->($name) };
        warn $@ if $@;

        while (my ($attr, $attr_expected) = each %expected) {
            if (defined $obj) {
                Test::More::is($obj->$attr, $attr_expected,
                         "parsed $attr of $name");
            }
            else {
                Test::More::fail("parsed $attr of $name");
                Test::More::diag("$name produced an undef object");
            }
        }
    }
}

=head2 plan_tests ITEM_LIST

This will take the test list and count the number of tests that would be run.
If called in void context, the plan will be set for you. If called in nonvoid
context, the number of tests will be returned.

=cut

sub plan_tests {
    my $tests = sum map {
        ref $_->[1] eq 'HASH'
        ? scalar keys %{ $_->[1] }
        : (@$_ - 1) / 2
    } @_;

    return $tests if defined wantarray;

    Test::More::plan tests => $tests;
}

1;


#!/usr/bin/env perl
package TAEB::Test::Items;
use TAEB::Test;
use List::Util 'sum';

sub import {
    my $self = shift;

    main->import('Test::More');

    plan_items(@_);
    test_items(@_);
}

1;


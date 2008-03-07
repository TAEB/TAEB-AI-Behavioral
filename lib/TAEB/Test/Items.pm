#!/usr/bin/env perl
package TAEB::Test::Items;
use TAEB::Test;
use List::Util 'sum';

sub import {
    my $self = shift;

    main->import('Test::More');

    plan tests => sum map { scalar keys %{ $_->[1] } } @_;
    test_items(@_);
}

1;


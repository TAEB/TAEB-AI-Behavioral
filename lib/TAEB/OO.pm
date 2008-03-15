#!/usr/bin/env perl
package TAEB::OO;
use Moose;

sub import {
    my $caller = caller;

    strict->import;
    warnings->import;

    return if $caller eq 'main';

    Moose::init_meta($caller);
    Moose->import({into => $caller});

    return 1;
}

1;


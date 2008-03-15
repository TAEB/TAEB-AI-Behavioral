#!/usr/bin/env perl
package TAEB::OO;
use Moose;
use TAEB::Meta::Class;

sub import {
    my $caller = caller;

    strict->import;
    warnings->import;

    return if $caller eq 'main';

    Moose::init_meta($caller, 'Moose::Object', 'TAEB::Meta::Class');
    Moose->import({into => $caller});

    return 1;
}

1;


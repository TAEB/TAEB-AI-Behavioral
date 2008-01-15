#!/usr/bin/env perl
package TAEB::Knowledge::Item::Ring;
use Moose;
extends 'TAEB::Knowledge::Item';

sub all_appearances {
    return @{ TAEB::Spoilers::Item::Ring->randomized_appearances };
}

sub all_identities {
    return keys %{ TAEB::Spoilers::Item::Ring->list };
}

1;


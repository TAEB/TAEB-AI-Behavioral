#!/usr/bin/env perl
package TAEB::Knowledge::Item::Wand;
use Moose;
extends 'TAEB::Knowledge::Item';

# XXX: these need to be taken from Spoilers
sub all_appearances {
    return qw/glass balsa crystal maple pine oak ebony marble tin brass copper
              silver platinum iridium zinc aluminum uranium iron steel
              hexagonal short runed long curved forked spiked jeweled/;
}

sub all_identities {
    return keys %{ TAEB::Spoilers::Item::Wand->list };
}

1;


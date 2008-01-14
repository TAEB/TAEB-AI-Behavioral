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
    return ('light', 'nothing', 'digging', 'enlightenment', 'locking',
            'magic missile', 'make invisible', 'opening', 'probing',
            'secret door detection', 'slow monster', 'speed monster',
            'striking', 'undead turning', 'cold', 'fire', 'lightning',
            'sleep', 'cancellation', 'create monster', 'polymorph',
            'teleportation', 'death', 'wishing');
}

1;


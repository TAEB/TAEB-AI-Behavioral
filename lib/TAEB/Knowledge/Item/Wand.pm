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

my @_groups = (
    [ 'cold'          ],
    [ 'polymorph'     ],
    [ 'speed monster' ],
    [ 'slow monster'  ],
    [ 'striking'      ],
    [ 'magic missile' ],
    [ 'light'         ],
    [ 'enlightenment' ],
    [ 'create monster'],
    [ 'digging'       ],
    [ 'fire'          ],
    [ 'lightning'     ],
    [ 'wishing'       ],

    [ qw/sleep death/ ],
    [ 'teleportation', 'make invisible', 'cancellation' ],

    # these no-message wands are excluded because we cannot distinguish
    # between engrave-giving-no-message and out-of-charges. bones piles, eg
    #[ 'locking', 'nothing', 'opening', 'probing', 'undead turning', 'secret door detection' ],
);

my @groups = map { { map { +"wand of $_" => 1 } @$_ } } @_groups;

sub engrave_useful {
    my $self = shift;

    # How this works is we group each wand identity based on what it would
    # do in an engrave ID. For example, sleep and death would go into one
    # group, and invis, tele, canc would go into another. If we have
    # possible identities from two or more groups, then engrave-IDing would
    # be useful in the sense that it'd rule some possibilities out.

    my $appearance_groups = 0;
    GROUP: for my $group (@groups) {
        for my $possibility ($self->possibilities) {
            next unless $group->{$possibility};
            return 1 if $appearance_groups++ > 0;
            next GROUP;
        }
    }

    return 0;
}

1;


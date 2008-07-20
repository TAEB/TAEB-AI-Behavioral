#!/usr/bin/env perl
package TAEB::Spoilers::Messages;
use MooseX::Singleton;

# Parts of the first line of the different quest entrance messages.
has quest_messages => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        # Someone please go grab the ranger message, kthx.
        my %quest_messages = (
            'Arc' => qr/You are suddenly in familiar surroundings\./,
            'Bar' => qr/Warily you scan your surroundings,/,
            'Cav' => qr/You descend through a barely familiar stairwell/,
            'Hea' => qr/What sorcery has brought you back to the Temple/,
            'Kni' => qr/You materialize in the shadows of Camelot Castle\./,
            'Mon' => qr/You find yourself standing in sight of the Monastery/,
            'Pri' => qr/You find yourself standing in sight of the Great/,
            'Ran' => qr/You arrive in familiar surroundings\./,
            'Sam' => qr/Even before your senses adjust, you recognize the kami/,
            'Tou' => qr/You breathe a sigh of relief as you find yourself/,
            'Val' => qr/You materialize at the base of a snowy hill\./,
            'Wiz' => qr/You are suddenly in familiar surroundings\./,
        );

        return \%quest_messages;
    },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


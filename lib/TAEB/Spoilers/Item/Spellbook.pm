#!/usr/bin/env perl
package TAEB::Spoilers::Item::Spellbook;
use MooseX::Singleton;
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $spellbooks = {
            'spellbook of blank paper' => {
                base       => 0,
                level      => 0,
                read       => 0,
                marker     => 0,
                appearance => 'plain spellbook',
            },
            'Book of the Dead' => {
                artifact   => 1,
                base       => 10000,
                weight     => 20,
                level      => 7,
                read       => 0,
                marker     => 0,
                appearance => 'papyrus spellbook',
            },
            'spellbook of force bolt' => {
                base   => 100,
                level  => 1,
                read   => 2,
                marker => 10,
            },
            'spellbook of drain life' => {
                base   => 200,
                level  => 2,
                read   => 2,
                marker => 20,
            },
            'spellbook of magic missile' => {
                base   => 200,
                level  => 2,
                read   => 2,
                marker => 20,
                role   => 'Wiz',
            },
            'spellbook of cone of cold' => {
                base   => 400,
                level  => 4,
                read   => 21,
                marker => 40,
                role   => 'Val',
            },
            'spellbook of fireball' => {
                base   => 400,
                level  => 4,
                read   => 12,
                marker => 40,
            },
            'spellbook of finger of death' => {
                base   => 700,
                level  => 7,
                read   => 80,
                marker => 70,
            },
            'spellbook of healing' => {
                base      => 100,
                level     => 1,
                read      => 2,
                marker    => 10,
                emergency => 1,
            },
            'spellbook of cure blindness' => {
                base      => 200,
                level     => 2,
                read      => 2,
                marker    => 20,
                emergency => 1,
            },
            'spellbook of cure sickness' => {
                base      => 300,
                level     => 3,
                read      => 6,
                marker    => 30,
                role      => 'Hea',
                emergency => 1,
            },
            'spellbook of extra healing' => {
                base      => 300,
                level     => 3,
                read      => 10,
                marker    => 30,
                emergency => 1,
            },
            'spellbook of stone to flesh' => {
                base   => 300,
                level  => 3,
                read   => 2,
                marker => 30,
            },
            'spellbook of restore ability' => {
                base      => 400,
                level     => 4,
                read      => 15,
                marker    => 40,
                role      => 'Mon',
                emergency => 1,
            },
            'spellbook of detect monsters' => {
                base   => 100,
                level  => 1,
                read   => 1,
                marker => 10,
            },
            'spellbook of light' => {
                base   => 100,
                level  => 1,
                read   => 1,
                marker => 10,
            },
            'spellbook of detect food' => {
                base   => 200,
                level  => 2,
                read   => 3,
                marker => 20,
            },
            'spellbook of clairvoyance' => {
                base   => 300,
                level  => 3,
                read   => 6,
                marker => 30,
                role   => 'Sam',
            },
            'spellbook of detect unseen' => {
                base   => 300,
                level  => 3,
                read   => 8,
                marker => 30,
            },
            'spellbook of identify' => {
                base   => 300,
                level  => 3,
                read   => 12,
                marker => 30,
            },
            'spellbook of detect treasure' => {
                base   => 400,
                level  => 4,
                read   => 15,
                marker => 40,
                role   => 'Rog',
            },
            'spellbook of magic mapping' => {
                base   => 500,
                level  => 5,
                read   => 35,
                marker => 50,
                role   => 'Arc',
            },
            'spellbook of sleep' => {
                base   => 100,
                level  => 1,
                read   => 1,
                marker => 10,
            },
            'spellbook of confuse monster' => {
                base   => 200,
                level  => 2,
                read   => 2,
                marker => 20,
            },
            'spellbook of slow monster' => {
                base   => 200,
                level  => 2,
                read   => 2,
                marker => 20,
            },
            'spellbook of cause fear' => {
                base   => 300,
                level  => 3,
                read   => 6,
                marker => 30,
            },
            'spellbook of charm monster' => {
                base   => 300,
                level  => 3,
                read   => 6,
                marker => 30,
                role   => 'Tou',
            },
            'spellbook of protection' => {
                base   => 100,
                level  => 1,
                read   => 3,
                marker => 10,
            },
            'spellbook of create monster' => {
                base   => 200,
                level  => 2,
                read   => 3,
                marker => 20,
            },
            'spellbook of remove curse' => {
                base      => 300,
                level     => 3,
                read      => 10,
                marker    => 30,
                role      => 'Pri',
                emergency => 1,
            },
            'spellbook of create familiar' => {
                base   => 600,
                level  => 6,
                read   => 42,
                marker => 60,
            },
            'spellbook of turn undead' => {
                base   => 600,
                level  => 6,
                read   => 48,
                marker => 60,
                role   => 'Kni',
            },
            'spellbook of jumping' => {
                base   => 100,
                level  => 1,
                read   => 3,
                marker => 10,
            },
            'spellbook of haste self' => {
                base   => 300,
                level  => 3,
                read   => 8,
                marker => 30,
                role   => 'Bar',
            },
            'spellbook of invisibility' => {
                base   => 400,
                level  => 4,
                read   => 15,
                marker => 40,
                role   => 'Ran',
            },
            'spellbook of levitation' => {
                base   => 400,
                level  => 4,
                read   => 12,
                marker => 40,
            },
            'spellbook of teleport away' => {
                base   => 600,
                level  => 6,
                read   => 36,
                marker => 60,
            },
            'spellbook of knock' => {
                base   => 100,
                level  => 1,
                read   => 1,
                marker => 10,
            },
            'spellbook of wizard lock' => {
                base   => 200,
                level  => 2,
                read   => 3,
                marker => 20,
            },
            'spellbook of dig' => {
                base   => 500,
                level  => 5,
                read   => 30,
                marker => 50,
                role   => 'Cav',
            },
            'spellbook of polymorph' => {
                base   => 600,
                level  => 6,
                read   => 48,
                marker => 60,
            },
            'spellbook of cancellation' => {
                base   => 700,
                level  => 7,
                read   => 64,
                marker => 70,
            },
        };

        # tag each spellbook with its name and weight
        for my $name (keys %$spellbooks) {
            my $stats = $spellbooks->{$name};
            $stats->{name}   = $name;
            $stats->{weight} = 50 unless $stats->{weight};
        }

        return $spellbooks;
    },
);

has randomized_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
        [map { "$_ spellbook" } (qw/parchment vellum ragged mottled stained
                                    cloth leather white pink red orange yellow
                                    velvet turquoise cyan indigo magenta purple
                                    violet tan plaid gray wrinkled dusty bronze
                                    copper silver gold glittering shining dull
                                    thin thick/,
                                 'dog eared', 'light green', 'dark green',
                                 'light blue', 'dark blue', 'light brown',
                                 'dark brown',
                                )]
    },
);

has constant_appearances => (
    is         => 'ro',
    isa        => 'HashRef',
    auto_deref => 1,
    default    => sub { {'plain spellbook'   => 'spellbook of blank paper',
                         'papyrus spellbook' => 'Book of the Dead'} },
);

has blind_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [ 'spellbook' ] },
);

sub spellbook {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

no Moose;

1;


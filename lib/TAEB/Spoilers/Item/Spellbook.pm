#!/usr/bin/env perl
package TAEB::Spoilers::Item::Spellbook;
use MooseX::Singleton;

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $books = {
            'spellbook of blank paper' => {
                cost       => 0,
                level      => 0,
                read       => 0,
                marker     => 0,
                appearance => 'plain spellbook',
            },
            'Book of the Dead' => {
                artifact   => 1,
                cost       => 10000,
                weight     => 20,
                level      => 7,
                read       => 0,
                marker     => 0,
                appearance => 'papyrus spellbook',
            },
            'spellbook of force bolt' => {
                cost   => 100,
                level  => 1,
                read   => 2,
                marker => 10,
            },
            'spellbook of drain life' => {
                cost   => 200,
                level  => 2,
                read   => 2,
                marker => 20,
            },
            'spellbook of magic missile' => {
                cost   => 200,
                level  => 2,
                read   => 2,
                marker => 20,
                role   => 'Wiz',
            },
            'spellbook of cone of cold' => {
                cost   => 400,
                level  => 4,
                read   => 21,
                marker => 40,
                role   => 'Val',
            },
            'spellbook of fireball' => {
                cost   => 400,
                level  => 4,
                read   => 12,
                marker => 40,
            },
            'spellbook of finger of death' => {
                cost   => 700,
                level  => 7,
                read   => 80,
                marker => 70,
            },
            'spellbook of healing' => {
                cost      => 100,
                level     => 1,
                read      => 2,
                marker    => 10,
                emergency => 1,
            },
            'spellbook of cure blindness' => {
                cost      => 200,
                level     => 2,
                read      => 2,
                marker    => 20,
                emergency => 1,
            },
            'spellbook of cure sickness' => {
                cost      => 300,
                level     => 3,
                read      => 6,
                marker    => 30,
                role      => 'Hea',
                emergency => 1,
            },
            'spellbook of extra healing' => {
                cost      => 300,
                level     => 3,
                read      => 10,
                marker    => 30,
                emergency => 1,
            },
            'spellbook of stone to flesh' => {
                cost   => 300,
                level  => 3,
                read   => 2,
                marker => 30,
            },
            'spellbook of restore ability' => {
                cost      => 400,
                level     => 4,
                read      => 15,
                marker    => 40,
                role      => 'Mon',
                emergency => 1,
            },
            'spellbook of detect monsters' => {
                cost   => 100,
                level  => 1,
                read   => 1,
                marker => 10,
            },
            'spellbook of light' => {
                cost   => 100,
                level  => 1,
                read   => 1,
                marker => 10,
            },
            'spellbook of detect food' => {
                cost   => 200,
                level  => 2,
                read   => 3,
                marker => 20,
            },
            'spellbook of clairvoyance' => {
                cost   => 300,
                level  => 3,
                read   => 6,
                marker => 30,
                role   => 'Sam',
            },
            'spellbook of detect unseen' => {
                cost   => 300,
                level  => 3,
                read   => 8,
                marker => 30,
            },
            'spellbook of identify' => {
                cost   => 300,
                level  => 3,
                read   => 12,
                marker => 30,
            },
            'spellbook of detect treasure' => {
                cost   => 400,
                level  => 4,
                read   => 15,
                marker => 40,
                role   => 'Rog',
            },
            'spellbook of magic mapping' => {
                cost   => 500,
                level  => 5,
                read   => 35,
                marker => 50,
                role   => 'Arc',
            },
            'spellbook of sleep' => {
                cost   => 100,
                level  => 1,
                read   => 1,
                marker => 10,
            },
            'spellbook of confuse monster' => {
                cost   => 200,
                level  => 2,
                read   => 2,
                marker => 20,
            },
            'spellbook of slow monster' => {
                cost   => 200,
                level  => 2,
                read   => 2,
                marker => 20,
            },
            'spellbook of cause fear' => {
                cost   => 300,
                level  => 3,
                read   => 6,
                marker => 30,
            },
            'spellbook of charm monster' => {
                cost   => 300,
                level  => 3,
                read   => 6,
                marker => 30,
                role   => 'Tou',
            },
            'spellbook of protection' => {
                cost   => 100,
                level  => 1,
                read   => 3,
                marker => 10,
            },
            'spellbook of create monster' => {
                cost   => 200,
                level  => 2,
                read   => 3,
                marker => 20,
            },
            'spellbook of remove curse' => {
                cost      => 300,
                level     => 3,
                read      => 10,
                marker    => 30,
                role      => 'Pri',
                emergency => 1,
            },
            'spellbook of create familiar' => {
                cost   => 600,
                level  => 6,
                read   => 42,
                marker => 60,
            },
            'spellbook of turn undead' => {
                cost   => 600,
                level  => 6,
                read   => 48,
                marker => 60,
                role   => 'Kni',
            },
            'spellbook of jumping' => {
                cost   => 100,
                level  => 1,
                read   => 3,
                marker => 10,
            },
            'spellbook of haste self' => {
                cost   => 300,
                level  => 3,
                read   => 8,
                marker => 30,
                role   => 'Bar',
            },
            'spellbook of invisibility' => {
                cost   => 400,
                level  => 4,
                read   => 15,
                marker => 40,
                role   => 'Ran',
            },
            'spellbook of levitation' => {
                cost   => 400,
                level  => 4,
                read   => 12,
                marker => 40,
            },
            'spellbook of teleport away' => {
                cost   => 600,
                level  => 6,
                read   => 36,
                marker => 60,
            },
            'spellbook of knock' => {
                cost   => 100,
                level  => 1,
                read   => 1,
                marker => 10,
            },
            'spellbook of wizard lock' => {
                cost   => 200,
                level  => 2,
                read   => 3,
                marker => 20,
            },
            'spellbook of dig' => {
                cost   => 500,
                level  => 5,
                read   => 30,
                marker => 50,
                role   => 'Cav',
            },
            'spellbook of polymorph' => {
                cost   => 600,
                level  => 6,
                read   => 48,
                marker => 60,
            },
            'spellbook of cancellation' => {
                cost   => 700,
                level  => 7,
                read   => 64,
                marker => 70,
            },
        };

        # tag each spellbook with its name and weight
        while (my ($name, $stats) = each %$books) {
            $stats->{name}   = $name;
            $stats->{weight} = 50 unless $stats->{weight};
        }

        return $books;
    },
);

sub spellbook {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


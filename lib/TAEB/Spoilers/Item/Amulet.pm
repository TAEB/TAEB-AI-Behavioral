#!/usr/bin/env perl
package TAEB::Spoilers::Item::Amulet;
use MooseX::Singleton;

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $amulets = {
            'amulet of change' => {
                cost   => 150,
                edible => 1,
            },
            'amulet of ESP' => {
                cost   => 150,
                edible => 1,
            },
            'amulet of life saving' => {
                cost   => 150,
            },
            'amulet of magical breathing' => {
                cost   => 150,
                edible => 1,
            },
            'amulet of reflection' => {
                cost   => 150,
            },
            'amulet of restful sleep' => {
                cost   => 150,
                edible => 1,
            },
            'amulet of strangulation' => {
                cost   => 150,
                edible => 1,
            },
            'amulet of unchanging' => {
                cost   => 150,
                edible => 1,
            },
            'amulet versus poison' => {
                cost   => 150,
                edible => 1,
            },
            'cheap plastic imitation Amulet of Yendor' => {
                cost   => 0,
            },
            'Amulet of Yendor' => {
                cost   => 30000,
            },
        };

        # tag each amulet with its name
        while (my ($name, $stats) = each %$amulets) {
            $stats->{name}   = $name;
            $stats->{weight} = 20;
        }

        return $amulets;
    },
);

sub amulet {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


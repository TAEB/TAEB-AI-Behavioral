#!/usr/bin/env perl
package TAEB::Spoilers::Item::Amulet;
use MooseX::Singleton;
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $amulets = {
            'Eye of the Aethiopica' => {
                base   => 4000,
                edible => 1,
                artifact => 1,
            },
            'amulet of change' => {
                base   => 150,
                edible => 1,
            },
            'amulet of ESP' => {
                base   => 150,
                edible => 1,
            },
            'amulet of life saving' => {
                base   => 150,
            },
            'amulet of magical breathing' => {
                base   => 150,
                edible => 1,
            },
            'amulet of reflection' => {
                base   => 150,
            },
            'amulet of restful sleep' => {
                base   => 150,
                edible => 1,
            },
            'amulet of strangulation' => {
                base   => 150,
                edible => 1,
            },
            'amulet of unchanging' => {
                base   => 150,
                edible => 1,
            },
            'amulet versus poison' => {
                base   => 150,
                edible => 1,
            },
            'cheap plastic imitation Amulet of Yendor' => {
                base   => 0,
                appearance => 'Amulet of Yendor',
            },
            'Amulet of Yendor' => {
                base   => 30000,
                appearance => 'Amulet of Yendor',
            },
        };

        # tag each amulet with its name and weight
        for my $name (keys %$amulets) {
            my $stats = $amulets->{$name};
            $stats->{name}   = $name;
            $stats->{weight} = 20;
            $stats->{no_plural} = 1;
        }

        return $amulets;
    },
);

has randomized_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
        [map { "$_ amulet" } qw/circular spherical oval triangular pyramidal
                                square concave hexagonal octagonal/];
    },
);

has multi_identity_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { ['Amulet of Yendor'] },
);

sub amulet {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


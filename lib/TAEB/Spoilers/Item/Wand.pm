#!/usr/bin/env perl
package TAEB::Spoilers::Item::Wand;
use MooseX::Singleton;
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $wands = {
            'wand of light' => {
                cost    => 100,
                charges => 15,
                type    => 'nodir',
            },
            'wand of nothing' => {
                cost    => 100,
                charges => 15,
                type    => 'beam',
            },
            'wand of digging' => {
                cost    => 150,
                charges => 8,
                type    => 'ray',
            },
            'wand of enlightenment' => {
                cost    => 150,
                charges => 15,
                type    => 'nodir',
            },
            'wand of locking' => {
                cost    => 150,
                charges => 8,
                type    => 'beam',
            },
            'wand of magic missile' => {
                cost    => 150,
                charges => 8,
                type    => 'ray',
            },
            'wand of make invisible' => {
                cost    => 150,
                charges => 8,
                type    => 'beam',
            },
            'wand of opening' => {
                cost    => 150,
                charges => 8,
                type    => 'beam',
            },
            'wand of probing' => {
                cost    => 150,
                charges => 8,
                type    => 'beam',
            },
            'wand of secret door detection' => {
                cost    => 150,
                charges => 15,
                type    => 'nodir',
            },
            'wand of slow monster' => {
                cost    => 150,
                charges => 8,
                type    => 'beam',
            },
            'wand of speed monster' => {
                cost    => 150,
                charges => 8,
                type    => 'beam',
            },
            'wand of striking' => {
                cost    => 150,
                charges => 8,
                type    => 'beam',
            },
            'wand of undead turning' => {
                cost    => 150,
                charges => 8,
                type    => 'beam',
            },
            'wand of cold' => {
                cost    => 175,
                charges => 8,
                type    => 'ray',
            },
            'wand of fire' => {
                cost    => 175,
                charges => 8,
                type    => 'ray',
            },
            'wand of lightning' => {
                cost    => 175,
                charges => 8,
                type    => 'ray',
            },
            'wand of sleep' => {
                cost    => 175,
                charges => 8,
                type    => 'ray',
            },
            'wand of cancellation' => {
                cost    => 200,
                charges => 8,
                type    => 'beam',
            },
            'wand of create monster' => {
                cost    => 200,
                charges => 15,
                type    => 'nodir',
            },
            'wand of polymorph' => {
                cost    => 200,
                charges => 8,
                type    => 'beam',
            },
            'wand of teleportation' => {
                cost    => 200,
                charges => 8,
                type    => 'beam',
            },
            'wand of death' => {
                cost    => 500,
                charges => 8,
                type    => 'ray',
            },
            'wand of wishing' => {
                cost    => 500,
                charges => 3,
                type    => 'nodir',
            },
        };

        # tag each wand with its name and weight
        while (my ($name, $stats) = each %$wands) {
            $stats->{name}   = $name;
            $stats->{weight} = 7;
            $stats->{no_plural} = 1;
        }

        return $wands;
    },
);

has randomized_appearances => (
    is        => 'ro',
    isa       => 'ArrayRef',
    autoderef => 1,
    default   => sub {
        [map { "$_ wand" } qw/glass balsa crystal maple pine oak ebony marble
                              tin brass copper silver platinum iridium zinc
                              aluminum uranium iron steel hexagonal short
                              runed long curved forked spiked jeweled/];
    },
);

sub wand {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


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
                base       => 100,
                maxcharges => 15,
                type       => 'nodir',
            },
            'wand of nothing' => {
                base       => 100,
                maxcharges => 15,
                type       => 'beam',
            },
            'wand of digging' => {
                base       => 150,
                maxcharges => 8,
                type       => 'ray',
            },
            'wand of enlightenment' => {
                base       => 150,
                maxcharges => 15,
                type       => 'nodir',
            },
            'wand of locking' => {
                base       => 150,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of magic missile' => {
                base       => 150,
                maxcharges => 8,
                type       => 'ray',
            },
            'wand of make invisible' => {
                base       => 150,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of opening' => {
                base       => 150,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of probing' => {
                base       => 150,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of secret door detection' => {
                base       => 150,
                maxcharges => 15,
                type       => 'nodir',
            },
            'wand of slow monster' => {
                base       => 150,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of speed monster' => {
                base       => 150,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of striking' => {
                base       => 150,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of undead turning' => {
                base       => 150,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of cold' => {
                base       => 175,
                maxcharges => 8,
                type       => 'ray',
            },
            'wand of fire' => {
                base       => 175,
                maxcharges => 8,
                type       => 'ray',
            },
            'wand of lightning' => {
                base       => 175,
                maxcharges => 8,
                type       => 'ray',
            },
            'wand of sleep' => {
                base       => 175,
                maxcharges => 8,
                type       => 'ray',
            },
            'wand of cancellation' => {
                base       => 200,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of create monster' => {
                base       => 200,
                maxcharges => 15,
                type       => 'nodir',
            },
            'wand of polymorph' => {
                base       => 200,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of teleportation' => {
                base       => 200,
                maxcharges => 8,
                type       => 'beam',
            },
            'wand of death' => {
                base       => 500,
                maxcharges => 8,
                type       => 'ray',
            },
            'wand of wishing' => {
                base       => 500,
                maxcharges => 3,
                type       => 'nodir',
            },
        };

        # tag each wand with its name and weight
        for my $name (keys %$wands) {
            my $stats = $wands->{$name};
            $stats->{name}   = $name;
            $stats->{weight} = 7;
            $stats->{no_plural} = 1;
        }

        return $wands;
    },
);

has randomized_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
        [map { "$_ wand" } qw/glass balsa crystal maple pine oak ebony marble
                              tin brass copper silver platinum iridium zinc
                              aluminum uranium iron steel hexagonal short
                              runed long curved forked spiked jeweled/];
    },
);

has blind_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { ['wand'] },
);

sub wand {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return unless $item;
    return $self->list->{$item};
}

no Moose;

1;


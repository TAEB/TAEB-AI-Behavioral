#!/usr/bin/env perl
package TAEB::Spoilers::Item::Potion;
use MooseX::Singleton;
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $potions = {
            'potion of booze' => {
                base => 50,
            },
            'potion of fruit juice' => {
                base => 50,
            },
            'potion of see invisible' => {
                base => 50,
            },
            'potion of sickness' => {
                base => 50,
            },
            'potion of confusion' => {
                base => 100,
            },
            'potion of extra healing' => {
                base => 100,
            },
            'potion of hallucination' => {
                base => 100,
            },
            'potion of healing' => {
                base => 100,
            },
            'potion of restore ability' => {
                base => 100,
            },
            'potion of sleeping' => {
                base => 100,
            },
            'potion of water' => {
                base       => 100,
                appearance => 'clear potion',
            },
            'potion of blindness' => {
                base => 150,
            },
            'potion of gain energy' => {
                base => 150,
            },
            'potion of invisibility' => {
                base => 150,
            },
            'potion of monster detection' => {
                base => 150,
            },
            'potion of object detection' => {
                base => 150,
            },
            'potion of enlightenment' => {
                base => 200,
            },
            'potion of full healing' => {
                base => 200,
            },
            'potion of levitation' => {
                base => 200,
            },
            'potion of polymorph' => {
                base => 200,
            },
            'potion of speed' => {
                base => 200,
            },
            'potion of acid' => {
                base => 250,
            },
            'potion of oil' => {
                base => 250,
            },
            'potion of gain ability' => {
                base => 300,
            },
            'potion of gain level' => {
                base => 300,
            },
            'potion of paralysis' => {
                base => 300,
            },
        };

        # tag each potion with its name and weight
        for my $name (keys %$potions) {
            my $stats = $potions->{$name};
            $stats->{name}   = $name;
            $stats->{weight} = 20;
            ($stats->{plural} = $name) =~ s/\bpotion\b/potions/;
        }

        return $potions;
    },
);

has randomized_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
        [map { "$_ potion" } (qw/ruby pink orange yellow emerald cyan magenta
                                purple-red puce milky swirly bubbly smoky
                                cloudy effervescent black golden brown fizzy
                                dark white murky/,
                              'dark green', 'sky blue', 'brilliant blue')
        ];
    },
);

has constant_appearances => (
    is         => 'ro',
    isa        => 'HashRef',
    auto_deref => 1,
    default    => sub { {'clear potion' => 'potion of water',
                         'potion of holy water'   => 'potion of water',
                         'potion of unholy water' => 'potion of water'} },
);

has blind_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [ 'potion' ] },
);

sub potion {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return unless $item;
    return $self->list->{$item};
}

sub pluralize_unided {
    my $self = shift;
    my $item = shift;

    $item =~ s/\bpotion\b/potions/;
    return $item;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


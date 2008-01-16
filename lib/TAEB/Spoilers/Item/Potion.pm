#!/usr/bin/env perl
package TAEB::Spoilers::Item::Potion;
use MooseX::Singleton;

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $potions = {
            'potion of booze' => {
                cost => 50,
            },
            'potion of fruit juice' => {
                cost => 50,
            },
            'potion of see invisible' => {
                cost => 50,
            },
            'potion of sickness' => {
                cost => 50,
            },
            'potion of confusion' => {
                cost => 100,
            },
            'potion of extra healing' => {
                cost => 100,
            },
            'potion of hallucination' => {
                cost => 100,
            },
            'potion of healing' => {
                cost => 100,
            },
            'potion of restore ability' => {
                cost => 100,
            },
            'potion of sleeping' => {
                cost => 100,
            },
            'potion of water' => {
                cost       => 100,
                appearance => 'clear',
            },
            'potion of blindness' => {
                cost => 150,
            },
            'potion of gain energy' => {
                cost => 150,
            },
            'potion of invisibility' => {
                cost => 150,
            },
            'potion of monster detection' => {
                cost => 150,
            },
            'potion of object detection' => {
                cost => 150,
            },
            'potion of enlightenment' => {
                cost => 200,
            },
            'potion of full healing' => {
                cost => 200,
            },
            'potion of levitation' => {
                cost => 200,
            },
            'potion of polymorph' => {
                cost => 200,
            },
            'potion of speed' => {
                cost => 200,
            },
            'potion of acid' => {
                cost => 250,
            },
            'potion of oil' => {
                cost => 250,
            },
            'potion of gain ability' => {
                cost => 300,
            },
            'potion of gain level' => {
                cost => 300,
            },
            'potion of paralysis' => {
                cost => 300,
            },
        };

        # tag each potion with its name and weight
        while (my ($name, $stats) = each %$potions) {
            $stats->{name}   = $name;
            $stats->{weight} = 20;
            $stats->{plural} = $name =~ s/potion/potions/;
        }

        return $potions;
    },
);

has randomized_appearances => (
    is        => 'ro',
    isa       => 'ArrayRef',
    autoderef => 1,
    default   => sub {
        [map { "$_ potion" } (qw/ruby pink orange yellow emerald cyan magenta
                                purple-red puce milky swirly bubbly smoky
                                cloudy effervescent black golden brown fizzy
                                dark white murky/,
                              'dark green', 'sky blue', 'brilliant blue')
        ];
    },
);

sub potion {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


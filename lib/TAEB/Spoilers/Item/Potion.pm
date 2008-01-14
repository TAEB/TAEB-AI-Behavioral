#!/usr/bin/env perl
package TAEB::Spoilers::Item::Potion;
use MooseX::Singleton;

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $potions = {
            'booze' => {
                cost => 50,
            },
            'fruit juice' => {
                cost => 50,
            },
            'see invisible' => {
                cost => 50,
            },
            'sickness' => {
                cost => 50,
            },
            'confusion' => {
                cost => 100,
            },
            'extra healing' => {
                cost => 100,
            },
            'hallucination' => {
                cost => 100,
            },
            'healing' => {
                cost => 100,
            },
            'restore ability' => {
                cost => 100,
            },
            'sleeping' => {
                cost => 100,
            },
            'water' => {
                cost       => 100,
                appearance => 'clear',
            },
            'blindness' => {
                cost => 150,
            },
            'gain energy' => {
                cost => 150,
            },
            'invisibility' => {
                cost => 150,
            },
            'monster detection' => {
                cost => 150,
            },
            'object detection' => {
                cost => 150,
            },
            'enlightenment' => {
                cost => 200,
            },
            'full healing' => {
                cost => 200,
            },
            'levitation' => {
                cost => 200,
            },
            'polymorph' => {
                cost => 200,
            },
            'speed' => {
                cost => 200,
            },
            'acid' => {
                cost => 250,
            },
            'oil' => {
                cost => 250,
            },
            'gain ability' => {
                cost => 300,
            },
            'gain level' => {
                cost => 300,
            },
            'paralysis' => {
                cost => 300,
            },
        };

        # tag each scroll with its name
        while (my ($name, $stats) = each %$potions) {
            $stats->{name} = $name;
        }

        return $potions;
    },
);

sub potion {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


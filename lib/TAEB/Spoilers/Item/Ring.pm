#!/usr/bin/env perl
package TAEB::Spoilers::Item::Ring;
use MooseX::Singleton;
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $rings = {
            'ring of adornment' => {
                base       => 100,
                chargeable => 1,
            },
            'ring of hunger' => {
                base => 100,
            },
            'ring of protection' => {
                base       => 100,
                chargeable => 1,
            },
            'ring of protection from shape changers' => {
                base => 100,
            },
            'ring of stealth' => {
                base => 100,
            },
            'ring of sustain ability' => {
                base => 100,
            },
            'ring of warning' => {
                base => 100,
            },
            'ring of aggravate monster' => {
                base => 150,
            },
            'ring of cold resistance' => {
                base => 150,
            },
            'ring of gain constitution' => {
                base       => 150,
                chargeable => 1,
            },
            'ring of gain strength' => {
                base       => 150,
                chargeable => 1,
            },
            'ring of increase accuracy' => {
                base       => 150,
                chargeable => 1,
            },
            'ring of increase damage' => {
                base       => 150,
                chargeable => 1,
            },
            'ring of invisibility' => {
                base => 150,
            },
            'ring of poison resistance' => {
                base => 150,
            },
            'ring of see invisible' => {
                base => 150,
            },
            'ring of shock resistance' => {
                base => 150,
            },
            'ring of fire resistance' => {
                base => 200,
            },
            'ring of free action' => {
                base => 200,
            },
            'ring of levitation' => {
                base => 200,
            },
            'ring of regeneration' => {
                base => 200,
            },
            'ring of searching' => {
                base => 200,
            },
            'ring of slow digestion' => {
                base => 200,
            },
            'ring of teleportation' => {
                base => 200,
            },
            'ring of conflict' => {
                base => 300,
            },
            'ring of polymorph' => {
                base => 300,
            },
            'ring of polymorph control' => {
                base => 300,
            },
            'ring of teleport control' => {
                base => 300,
            },
        };

        # tag each ring with its name
        for my $name (keys %$rings) {
            my $stats = $rings->{$name};
            $stats->{name}   = $name;
            $stats->{weight} = 3 unless $stats->{weight};
            $stats->{no_plural} = 1;
        }

        return $rings;
    },
);

has randomized_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
        [map { "$_ ring" } (qw/wooden granite opal clay coral moonstone jade
                               bronze agate topaz sapphire ruby diamond pearl
                               iron brass copper twisted steel silver gold ivory
                               emerald wire engagement shiny/,
                            'black onyx', 'tiger eye')
        ];
    }
);

has blind_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [ 'ring' ] },
);

sub ring {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

no Moose;

1;


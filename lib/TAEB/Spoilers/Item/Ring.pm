#!/usr/bin/env perl
package TAEB::Spoilers::Item::Ring;
use MooseX::Singleton;

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $rings = {
            'meat ring' => {
                cost   => 5,
                weight => 1,
            },
            'ring of adornment' => {
                cost       => 100,
                chargeable => 1,
            },
            'ring of hunger' => {
                cost => 100,
            },
            'ring of protection' => {
                cost       => 100,
                chargeable => 1,
            },
            'ring of protection from shape changers' => {
                cost => 100,
            },
            'ring of stealth' => {
                cost => 100,
            },
            'ring of sustain ability' => {
                cost => 100,
            },
            'ring of warning' => {
                cost => 100,
            },
            'ring of aggravate monster' => {
                cost => 150,
            },
            'ring of cold resistance' => {
                cost => 150,
            },
            'ring of gain constitution' => {
                cost       => 150,
                chargeable => 1,
            },
            'ring of gain strength' => {
                cost       => 150,
                chargeable => 1,
            },
            'ring of increase accuracy' => {
                cost       => 150,
                chargeable => 1,
            },
            'ring of increase damage' => {
                cost       => 150,
                chargeable => 1,
            },
            'ring of invisibility' => {
                cost => 150,
            },
            'ring of poison resistance' => {
                cost => 150,
            },
            'ring of see invisible' => {
                cost => 150,
            },
            'ring of shock resistance' => {
                cost => 150,
            },
            'ring of fire resistance' => {
                cost => 200,
            },
            'ring of free action' => {
                cost => 200,
            },
            'ring of levitation' => {
                cost => 200,
            },
            'ring of regeneration' => {
                cost => 200,
            },
            'ring of searching' => {
                cost => 200,
            },
            'ring of slow digestion' => {
                cost => 200,
            },
            'ring of teleportation' => {
                cost => 200,
            },
            'ring of conflict' => {
                cost => 300,
            },
            'ring of polymorph' => {
                cost => 300,
            },
            'ring of polymorph control' => {
                cost => 300,
            },
            'ring of teleport control' => {
                cost => 300,
            },
        };

        # tag each ring with its name
        while (my ($name, $stats) = each %$rings) {
            $stats->{name}   = $name;
            $stats->{weight} = 3 unless $stats-{weight};
        }

        return $rings;
    },
);

sub ring {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


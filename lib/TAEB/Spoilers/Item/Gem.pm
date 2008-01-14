#!/usr/bin/env perl
package TAEB::Spoilers::Item::Gem;
use MooseX::Singleton;

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $gems = {
            'Heart of Ahriman' => {
                cost    => 2500,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray',
            },
            'dilithium crystal' => {
                cost    => 4500,
                weight  => 1,
                engrave => 'soft',
                appearance => 'white',
            },
            'diamond' => {
                cost    => 4000,
                weight  => 1,
                engrave => 'hard',
                appearance => 'white',
            },
            'ruby' => {
                cost    => 3500,
                weight  => 1,
                engrave => 'hard',
                appearance => 'red',
            },
            'jacinth' => {
                cost    => 3250,
                weight  => 1,
                engrave => 'hard',
                appearance => 'orange',
            },
            'sapphire' => {
                cost    => 3000,
                weight  => 1,
                engrave => 'hard',
                appearance => 'blue',
            },
            'black opal' => {
                cost    => 2500,
                weight  => 1,
                engrave => 'hard',
                appearance => 'black',
            },
            'emerald' => {
                cost    => 2500,
                weight  => 1,
                engrave => 'hard',
                appearance => 'green',
            },
            'turquoise' => {
                cost    => 2000,
                weight  => 1,
                engrave => 'soft',
                appearance => [qw/green blue/],
            },
            'aquamarine' => {
                cost    => 1500,
                weight  => 1,
                engrave => 'hard',
                appearance => [qw/green blue/],
            },
            'citrine' => {
                cost    => 1500,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellow',
            },
            'amber' => {
                cost    => 1000,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellowish brown',
            },
            'topaz' => {
                cost    => 900,
                weight  => 1,
                engrave => 'hard',
                appearance => 'yellowish brown',
            },
            'jet' => {
                cost    => 850,
                weight  => 1,
                engrave => 'soft',
                appearance => 'black',
            },
            'opal' => {
                cost    => 800,
                weight  => 1,
                engrave => 'soft',
                appearance => 'white',
            },
            'chrysoberyl' => {
                cost    => 700,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellow',
            },
            'garnet' => {
                cost    => 700,
                weight  => 1,
                engrave => 'soft',
                appearance => 'red',
            },
            'amethyst' => {
                cost    => 600,
                weight  => 1,
                engrave => 'soft',
                appearance => 'violet',
            },
            'jasper' => {
                cost    => 500,
                weight  => 1,
                engrave => 'soft',
                appearance => 'red',
            },
            'fluorite' => {
                cost    => 400,
                weight  => 1,
                engrave => 'soft',
                appearance => [qw/green blue white violet/],
            },
            'jade' => {
                cost    => 300,
                weight  => 1,
                engrave => 'soft',
                appearance => 'green',
            },
            'agate' => {
                cost    => 200,
                weight  => 1,
                engrave => 'soft',
                appearance => 'orange',
            },
            'obsidian' => {
                cost    => 200,
                weight  => 1,
                engrave => 'soft',
                appearance => 'black',
            },
            'black glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'black',
            },
            'blue glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'blue',
            },
            'green glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'green',
            },
            'orange glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'orange',
            },
            'red glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'red',
            },
            'violet glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'violet',
            },
            'white glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'white',
            },
            'yellow glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellow',
            },
            'yellowish brown glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellowish brown',
            },
            'luckstone' => {
                cost    => 60,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray stone',
            },
            'touchstone' => {
                cost    => 45,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray stone',
            },
            'flintstone' => {
                cost    => 1,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray stone',
            },
            'loadstone' => {
                cost    => 1,
                weight  => 500,
                engrave => 'soft',
                appearance => 'gray stone',
            },
            'rock' => {
                cost    => 0,
                weight  => 10,
                engrave => 'soft',
                appearance => 'rock',
            },
        };

        # tag each gem with its name
        while (my ($name, $stats) = each %$gems) {
            $stats->{name}   = $name;
        }

        return $gems;
    },
);

sub gem {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


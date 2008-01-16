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
                artifact => 1,
                cost    => 2500,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray stone',
            },
            'dilithium crystal' => {
                cost    => 4500,
                weight  => 1,
                engrave => 'soft',
                appearance => 'white gem',
                plural  => 'dilithium crystals',
            },
            'diamond' => {
                cost    => 4000,
                weight  => 1,
                engrave => 'hard',
                appearance => 'white gem',
                plural  => 'diamonds',
            },
            'ruby' => {
                cost    => 3500,
                weight  => 1,
                engrave => 'hard',
                appearance => 'red gem',
                plural  => 'rubies',
            },
            'jacinth stone' => {
                cost    => 3250,
                weight  => 1,
                engrave => 'hard',
                appearance => 'orange gem',
            },
            'sapphire' => {
                cost    => 3000,
                weight  => 1,
                engrave => 'hard',
                appearance => 'blue gem',
                plural  => 'sapphires',
            },
            'black opal' => {
                cost    => 2500,
                weight  => 1,
                engrave => 'hard',
                appearance => 'black gem',
                plural  => 'black opals',
            },
            'emerald' => {
                cost    => 2500,
                weight  => 1,
                engrave => 'hard',
                appearance => 'green gem',
                plural  => 'emeralds',
            },
            'turquoise stone' => {
                cost    => 2000,
                weight  => 1,
                engrave => 'soft',
                #appearance => [qw/green blue/],
                appearance => 'green gem',
            },
            'aquamarine stone' => {
                cost    => 1500,
                weight  => 1,
                engrave => 'hard',
                #appearance => [qw/green blue/],
                appearance => 'green gem',
            },
            'citrine stone' => {
                cost    => 1500,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellow gem',
            },
            'amber stone' => {
                cost    => 1000,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellowish brown gem',
            },
            'topaz stone' => {
                cost    => 900,
                weight  => 1,
                engrave => 'hard',
                appearance => 'yellowish brown gem',
            },
            'jet stone' => {
                cost    => 850,
                weight  => 1,
                engrave => 'soft',
                appearance => 'black gem',
            },
            'opal' => {
                cost    => 800,
                weight  => 1,
                engrave => 'soft',
                appearance => 'white gem',
                plural  => 'opals',
            },
            'chrysoberyl stone' => {
                cost    => 700,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellow gem',
            },
            'garnet stone' => {
                cost    => 700,
                weight  => 1,
                engrave => 'soft',
                appearance => 'red gem',
            },
            'amethyst stone' => {
                cost    => 600,
                weight  => 1,
                engrave => 'soft',
                appearance => 'violet gem',
            },
            'jasper stone' => {
                cost    => 500,
                weight  => 1,
                engrave => 'soft',
                appearance => 'red gem',
            },
            'fluorite stone' => {
                cost    => 400,
                weight  => 1,
                engrave => 'soft',
                #appearance => [qw/green blue white violet/],
                appearance => 'green gem',
            },
            'jade stone' => {
                cost    => 300,
                weight  => 1,
                engrave => 'soft',
                appearance => 'green gem',
            },
            'agate stone' => {
                cost    => 200,
                weight  => 1,
                engrave => 'soft',
                appearance => 'orange gem',
            },
            'obsidian stone' => {
                cost    => 200,
                weight  => 1,
                engrave => 'soft',
                appearance => 'black gem',
            },
            'worthless piece of black glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'black gem',
            },
            'worthless piece of blue glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'blue gem',
            },
            'worthless piece of green glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'green gem',
            },
            'worthless piece of orange glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'orange gem',
            },
            'worthless piece of red glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'red gem',
            },
            'worthless piece of violet glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'violet gem',
            },
            'worthless piece of white glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'white gem',
            },
            'worthless piece of yellow glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellow gem',
            },
            'worthless piece of yellowish brown glass' => {
                cost    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellowish brown gem',
            },
            'luckstone' => {
                cost    => 60,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray stone',
                plural  => 'luckstones',
            },
            'touchstone' => {
                cost    => 45,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray stone',
                plural  => 'touchstones',
            },
            'flint stone' => {
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
                plural  => 'loadstones',
            },
            'rock' => {
                cost    => 0,
                weight  => 10,
                engrave => 'soft',
                appearance => 'rock',
                plural  => 'rocks',
            },
        };

        # tag each gem with its name and fill in the rest of the plurals
        while (my ($name, $stats) = each %$gems) {
            $stats->{name}   = $name;
            $stats->{plural} = $name =~ s/ stone$/ stones/
                unless $stats->{plural};
            $stats->{plural} = $name =~ s/ piece / pieces /
                unless $stats->{plural};
        }

        return $gems;
    },
);

has multi_identity_appearances => (
    is        => 'ro',
    isa       => 'ArrayRef',
    autoderef => 1,
    default   => sub {
        [map { "$_ gem" } (qw/white red blue orange black green yellow violet/,
                           'yellowish brown'), 'gray stone'];
    },
);

has constant_appearances => (
    is        => 'ro',
    isa       => 'ArrayRef',
    autoderef => 1,
    default   => sub { ['rock'] },
);

sub gem {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


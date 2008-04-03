#!/usr/bin/env perl
package TAEB::Spoilers::Item::Gem;
use MooseX::Singleton;
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $gems = {
            'Heart of Ahriman' => {
                artifact => 1,
                base    => 2500,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray stone',
            },
            'dilithium crystal' => {
                base    => 4500,
                weight  => 1,
                engrave => 'soft',
                appearance => 'white gem',
                plural  => 'dilithium crystals',
            },
            'diamond' => {
                base    => 4000,
                weight  => 1,
                engrave => 'hard',
                appearance => 'white gem',
                plural  => 'diamonds',
            },
            'ruby' => {
                base    => 3500,
                weight  => 1,
                engrave => 'hard',
                appearance => 'red gem',
                plural  => 'rubies',
            },
            'jacinth stone' => {
                base    => 3250,
                weight  => 1,
                engrave => 'hard',
                appearance => 'orange gem',
            },
            'sapphire' => {
                base    => 3000,
                weight  => 1,
                engrave => 'hard',
                appearance => 'blue gem',
                plural  => 'sapphires',
            },
            'black opal' => {
                base    => 2500,
                weight  => 1,
                engrave => 'hard',
                appearance => 'black gem',
                plural  => 'black opals',
            },
            'emerald' => {
                base    => 2500,
                weight  => 1,
                engrave => 'hard',
                appearance => 'green gem',
                plural  => 'emeralds',
            },
            'turquoise stone' => {
                base    => 2000,
                weight  => 1,
                engrave => 'soft',
                #appearance => [qw/green blue/],
                appearance => 'green gem',
            },
            'aquamarine stone' => {
                base    => 1500,
                weight  => 1,
                engrave => 'hard',
                #appearance => [qw/green blue/],
                appearance => 'green gem',
            },
            'citrine stone' => {
                base    => 1500,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellow gem',
            },
            'amber stone' => {
                base    => 1000,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellowish brown gem',
            },
            'topaz stone' => {
                base    => 900,
                weight  => 1,
                engrave => 'hard',
                appearance => 'yellowish brown gem',
            },
            'jet stone' => {
                base    => 850,
                weight  => 1,
                engrave => 'soft',
                appearance => 'black gem',
            },
            'opal' => {
                base    => 800,
                weight  => 1,
                engrave => 'soft',
                appearance => 'white gem',
                plural  => 'opals',
            },
            'chrysoberyl stone' => {
                base    => 700,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellow gem',
            },
            'garnet stone' => {
                base    => 700,
                weight  => 1,
                engrave => 'soft',
                appearance => 'red gem',
            },
            'amethyst stone' => {
                base    => 600,
                weight  => 1,
                engrave => 'soft',
                appearance => 'violet gem',
            },
            'jasper stone' => {
                base    => 500,
                weight  => 1,
                engrave => 'soft',
                appearance => 'red gem',
            },
            'fluorite stone' => {
                base    => 400,
                weight  => 1,
                engrave => 'soft',
                #appearance => [qw/green blue white violet/],
                appearance => 'green gem',
            },
            'jade stone' => {
                base    => 300,
                weight  => 1,
                engrave => 'soft',
                appearance => 'green gem',
            },
            'agate stone' => {
                base    => 200,
                weight  => 1,
                engrave => 'soft',
                appearance => 'orange gem',
            },
            'obsidian stone' => {
                base    => 200,
                weight  => 1,
                engrave => 'soft',
                appearance => 'black gem',
            },
            'worthless piece of black glass' => {
                base    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'black gem',
            },
            'worthless piece of blue glass' => {
                base    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'blue gem',
            },
            'worthless piece of green glass' => {
                base    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'green gem',
            },
            'worthless piece of orange glass' => {
                base    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'orange gem',
            },
            'worthless piece of red glass' => {
                base    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'red gem',
            },
            'worthless piece of violet glass' => {
                base    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'violet gem',
            },
            'worthless piece of white glass' => {
                base    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'white gem',
            },
            'worthless piece of yellow glass' => {
                base    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellow gem',
            },
            'worthless piece of yellowish brown glass' => {
                base    => 0,
                weight  => 1,
                engrave => 'soft',
                appearance => 'yellowish brown gem',
            },
            'luckstone' => {
                base    => 60,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray stone',
                plural  => 'luckstones',
            },
            'touchstone' => {
                base    => 45,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray stone',
                plural  => 'touchstones',
            },
            'flint stone' => {
                base    => 1,
                weight  => 10,
                engrave => 'soft',
                appearance => 'gray stone',
            },
            'loadstone' => {
                base    => 1,
                weight  => 500,
                engrave => 'soft',
                appearance => 'gray stone',
                plural  => 'loadstones',
            },
            'rock' => {
                base    => 0,
                weight  => 10,
                engrave => 'soft',
                appearance => 'rock',
                plural  => 'rocks',
            },
        };

        # tag each gem with its name and fill in the rest of the plurals
        for my $name (keys %$gems) {
            my $stats = $gems->{$name};
            $stats->{name}   = $name;
            ($stats->{plural} = $name) =~ s/ stone$/ stones/
                unless $stats->{plural};
            ($stats->{plural} = $name) =~ s/ piece / pieces /
                unless $stats->{plural};
        }

        return $gems;
    },
);

has multi_identity_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
        [(map { "$_ gem" } (qw/white red blue orange black green yellow violet/,
                           'yellowish brown')), 'gray stone'];
    },
);

has constant_appearances => (
    is         => 'ro',
    isa        => 'HashRef',
    auto_deref => 1,
    default    => sub { {rock => 'rock'} },
);

has blind_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [qw/stone gem/] },
);

sub gem {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return unless $item;
    return $self->list->{$item};
}

sub pluralize_unided {
    my $self = shift;
    my $item = shift;

    $item =~ s/\b(gem|stone|rock)\b/$1s/;
    return $item;
}

no Moose;

1;


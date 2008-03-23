#!/usr/bin/env perl
package TAEB::Spoilers::Item::Other;
use MooseX::Singleton;
use TAEB::Util ':colors';
extends 'TAEB::Spoilers::Item';

use TAEB::Spoilers::Monster; # for statues

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $other = {
            'gold piece' => {
                base   => 1,
                weight => 0.01,
                glyph  => '$',
                plural => 'gold pieces',
            },
            'boulder' => {
                base      => 0,
                weight    => 6000,
                glyph     => '0',
                sdam      => 'd20',
                ldam      => 'd20',
                nutrition => 2000,
                plural    => 'boulders',
            },
            'statue' => {
                base      => 0,
                weight    => 900,
                glyph     => '`',
                sdam      => 'd20',
                ldam      => 'd20',
                nutrition => 2500,
                plural    => 'statues',
            },
            'heavy iron ball' => {
                base      => 10,
                weight    => 480,
                glyph     => '0',
                sdam      => 'd25',
                ldam      => 'd25',
                nutrition => 480,
                plural    => 'heavy iron balls',
            },
            'iron chain' => {
                base      => 0,
                weight    => 120,
                glyph     => '_',
                sdam      => 'd4+1',
                ldam      => 'd4+1',
                nutrition => 120,
                plural    => 'iron chains',
            },
            'acid venom' => {
                base   => 0,
                weight => 1,
                glyph  => '.',
                color  => COLOR_BROWN,
                sdam   => '2d6',
                ldam   => '2d6',
                plural => 'acid venoms',
            },
            'blinding venom' => {
                base   => 0,
                weight => 1,
                glyph  => '.',
                color  => COLOR_BROWN,
                plural => 'blinding venoms',
            },
        };

        # Collect monster statues
        my $monsterlist = TAEB::Spoilers::Monster->list;
        for my $name (keys %$monsterlist) {
            my $stats = $monsterlist->{$name};
            $other->{"statue of $stats->{an} $name"} = {
                %{ $other->{statue} },
                plural => "statues of $name",
            };
        }

        # tag each other item with its name
        for my $name (keys %$other) {
            my $stats = $other->{$name};
            $stats->{name} = $name;

            # everything actually has the same appearance as identity
            $stats->{appearance} = $name;
        }

        return $other;
    },
);

has constant_appearances => (
    is         => 'ro',
    isa        => 'HashRef',
    auto_deref => 1,
    lazy       => 1,
    default    => sub {
        my $self = shift;
        my $appearances = {};
        for my $item (keys %{ $self->list }) {
            my $stats = $self->list->{$item};
            $appearances->{$stats->{appearance}} = $stats->{name}
        }
        return $appearances;
    },
);

sub other {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

no Moose;

1;


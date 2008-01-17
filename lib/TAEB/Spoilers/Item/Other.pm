#!/usr/bin/env perl
package TAEB::Spoilers::Item::Other;
use MooseX::Singleton;
use TAEB::Util ':colors';
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $other {
            'gold piece' => {
                cost   => 1,
                weight => 0.01,
            },
            'boulder' => {
                cost      => 0,
                weight    => 6000,
                glyph     => '0',
                sdam      => 'd20',
                ldam      => 'd20',
                nutrition => 2000,
            },
            'statue' => {
                cost      => 0,
                weight    => 900,
                glyph     => '`',
                sdam      => 'd20',
                ldam      => 'd20',
                nutrition => 2500,
            },
            'heavy iron ball' => {
                cost      => 10,
                weight    => 480,
                glyph     => '0',
                sdam      => 'd25',
                ldam      => 'd25',
                nutrition => 480,
            },

            'iron chain' => {
                cost      => 0,
                weight    => 120,
                glyph     => '_',
                sdam      => 'd4+1',
                ldam      => 'd4+1',
                nutrition => 120,
            },
            'acid venom' => {
                cost   => 0,
                weight => 1,
                glyph  => '.',
                color  => COLOR_BROWN,
                sdam   => '2d6',
                ldam   => '2d6',
            },
            'blinding venom' => {
                cost   => 0,
                weight => 1,
                glyph  => '.',
                color  => COLOR_BROWN,
            },
        };

        # tag each other item with its name
        while (my ($name, $stats) = each %$other) {
            $stats->{name} = $name;
        }

        return $other;
    },
);

sub other {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


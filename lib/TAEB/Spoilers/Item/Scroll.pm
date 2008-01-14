#!/usr/bin/env perl
package TAEB::Spoilers::Item::Scroll;
use MooseX::Singleton;

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $scrolls = {
            'mail' => {
                cost       => 0,
                marker     => 2,
                appearance => 'stamped',
            },
            'identify' => {
                cost   => 20,
                marker => 14,
            },
            'light' => {
                cost   => 50,
                marker => 8,
            },
            'blank paper' => {
                cost       => 60,
                marker     => 0,
                appearance => 'unlabeled',
            },
            'enchant weapon' => {
                cost   => 60,
                marker => 16,
            },
            'enchant armor' => {
                cost   => 80,
                marker => 16,
            },
            'remove curse' => {
                cost   => 80,
                marker => 16,
            },
            'confuse monster' => {
                cost   => 100,
                marker => 12,
            },
            'destroy armor' => {
                cost   => 100,
                marker => 10,
            },
            'fire' => {
                cost   => 100,
                marker => 8,
            },
            'food detection' => {
                cost   => 100,
                marker => 8,
            },
            'gold detection' => {
                cost   => 100,
                marker => 8,
            },
            'magic mapping' => {
                cost   => 100,
                marker => 8,
            },
            'scare monster' => {
                cost   => 100,
                marker => 20,
            },
            'teleportation' => {
                cost   => 100,
                marker => 20,
            },
            'amnesia' => {
                cost   => 200,
                marker => 8,
            },
            'create monster' => {
                cost   => 200,
                marker => 10,
            },
            'earth' => {
                cost   => 200,
                marker => 8,
            },
            'taming' => {
                cost   => 200,
                marker => 20,
            },
            'charging' => {
                cost   => 300,
                marker => 16,
            },
            'genocide' => {
                cost   => 300,
                marker => 30,
            },
            'punishment' => {
                cost   => 300,
                marker => 10,
            },
            'stinking cloud' => {
                cost   => 300,
                marker => 20,
            },
        };

        # tag each scroll with its name
        while (my ($name, $stats) = each %$scrolls) {
            $stats->{name} = $name;
        }

        return $scrolls;
    },
);

sub scroll {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


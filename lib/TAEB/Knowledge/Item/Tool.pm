#!/usr/bin/env perl
package TAEB::Knowledge::Item::Tool;
use MooseX::Singleton;

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $tools = {
            'Bell of Opening' => {
                artifact => 1,
                cost => 5000,
                weight => 10,
                charge => 3,
                appearance => 'silver bell',
            },
            'Candelabrum of Invocation' => {
                artifact => 1,
                cost => 5000,
                weight => 10,
                charge => '',
                appearance => 'candelabrum',
            },
            'Eyes of the Overworld' => {
                artifact => 1,
                cost => 80,
                weight => 3,
                charge => '',
            },
            'Magic Mirror of Merlin' => {
                artifact => 1,
                cost => 10,
                weight => 13,
                charge => '',
            },
            'Master Key of Thievery' => {
                artifact => 1,
                cost => 10,
                weight => 3,
                charge => '',
            },
            'Orb of Detection' => {
                artifact => 1,
                cost => 60,
                weight => 150,
                charge => 5,
            },
            'Orb of Fate' => {
                artifact => 1,
                cost => 60,
                weight => 150,
                charge => 5,
            },
            'Platinum Yendorian Express Card' => {
                artifact => 1,
                cost => 10,
                weight => 1,
                charge => '',
            },
            'sack' => {
                cost => 2,
                weight => 15,
                charge => '',
                appearance => 'bag',
            },
            'large box' => {
                cost => 8,
                weight => 350,
                charge => '',
            },
            'chest' => {
                cost => 16,
                weight => 600, charge => '',
            },
            'ice box' => {
                cost => 42,
                weight => 900,
                charge => '',
            },
            'bag of holding' => {
                cost => 100,
                weight => 15,
                charge => '',
                appearance => 'bag',
            },
            'bag of tricks' => {
                cost => 100,
                weight => 15,
                charge => 20,
                appearance => 'bag',
            },
            'oilskin sack' => {
                cost => 100,
                weight => 15,
                charge => '',
                appearance => 'bag',
            },
            'credit card' => {
                cost => 10,
                weight => 1,
                charge => '',
            },
            'lock pick' => {
                cost => 20,
                weight => 4,
                charge => '',
            },
            'skeleton key' => {
                cost => 10,
                weight => 3,
                charge => '',
                appearance => 'key',
            },
            'tallow candle' => {
                cost => 10,
                weight => 2,
                charge => '',
                appearance => 'candle',
            },
            'wax candle' => {
                cost => 20,
                weight => 2,
                charge => '',
                appearance => 'candle',
            },
            'brass lantern' => {
                cost => 12,
                weight => 30,
                charge => 1499,
            },
            'oil lamp' => {
                cost => 10,
                weight => 20,
                charge => 1499,
                appearance => 'lamp',
            },
            'magic lamp' => {
                cost => 50,
                weight => 20,
                charge => '',
                appearance => 'lamp',
            },
            'tin whistle' => {
                cost => 10,
                weight => 3,
                charge => '',
                appearance => 'whistle',
            },
            'magic whistle' => {
                cost => 10,
                weight => 3,
                charge => '',
                appearance => 'whistle',
            },
            'bugle' => {
                cost => 15,
                weight => 10,
                charge => '',
            },
            'wooden flute' => {
                cost => 12,
                weight => 5,
                charge => '',
                appearance => 'flute',
            },
            'magic flute' => {
                cost => 36,
                weight => 5,
                charge => 8,
                appearance => 'flute',
            },
            'tooled horn' => {
                cost => 15,
                weight => 18,
                charge => '',
                appearance => 'horn',
            },
            'frost horn' => {
                cost => 50,
                weight => 18,
                charge => 8,
                appearance => 'horn',
            },
            'fire horn' => {
                cost => 50,
                weight => 18,
                charge => 8,
                appearance => 'horn',
            },
            'horn of plenty' => {
                cost => 50,
                weight => 18,
                charge => 20,
                appearance => 'horn',
            },
            'leather drum' => {
                cost => 25,
                weight => 25,
                charge => '',
                appearance => 'drum',
            },
            'drum of earthquake' => {
                cost => 25,
                weight => 25,
                charge => 8,
                appearance => 'drum',
            },
            'wooden harp' => {
                cost => 50,
                weight => 30,
                charge => '',
                appearance => 'harp',
            },
            'magic harp' => {
                cost => 50,
                weight => 30,
                charge => 8,
                appearance => 'harp',
            },
            'bell' => {
                cost => 50,
                weight => 30,
                charge => '',
            },
            'beartrap' => {
                cost => 60,
                weight => 200,
                charge => '',
            },
            'land mine' => {
                cost => 180,
                weight => 300,
                charge => '',
                appearance => 'land mine',
            },
            'pick-axe' => {
                cost => 50,
                weight => 100,
                charge => '',
            },
            'grappling hook' => {
                cost => 50,
                weight => 30,
                charge => '',
                appearance => 'iron hook',
            },
            'unicorn horn' => {
                cost => 100,
                weight => 20,
                charge => '',
            },
            'expensive camera' => {
                cost => 200,
                weight => 12,
                charge => 99,
            },
            'mirror' => {
                cost => 10,
                weight => 13,
                charge => '',
                appearance => 'looking glass',
            },
            'crystal ball' => {
                cost => 60,
                weight => 150,
                charge => 5,
                appearance => 'glass orb',
            },
            'lenses' => {
                cost => 80,
                weight => 3,
                charge => '',
            },
            'blindfold' => {
                cost => 20,
                weight => 2,
                charge => '',
            },
            'towel' => {
                cost => 50,
                weight => 2,
                charge => '',
            },
            'saddle' => {
                cost => 150,
                weight => 200,
                charge => '',
            },
            'leash' => {
                cost => 20,
                weight => 12,
                charge => '',
            },
            'stethoscope' => {
                cost => 75,
                weight => 4,
                charge => '',
            },
            'tinning kit' => {
                cost => 30,
                weight => 100,
                charge => 99,
            },
            'tin opener' => {
                cost => 30,
                weight => 4,
                charge => '',
            },
            'can of grease' => {
                cost => 20,
                weight => 15,
                charge => 25,
            },
            'figurine' => {
                cost => 80,
                weight => 50,
                charge => '',
            },
            'magic marker' => {
                cost => 50,
                weight => 2,
                charge => 99,
            },
        };

        # tag each tool with its name
        while (my ($name, $stats) = each %$tools) {
            $stats->{name} = $name;
            $stats->{appearance} = $name unless $stats->{appearance};
        }

        return $tools;
    },
);

sub tool {
    my $self = shift;
    my $item = TAEB::Knowledge::Item->canonicalize_item(shift);

    return $self->list->{$item};
}

1;


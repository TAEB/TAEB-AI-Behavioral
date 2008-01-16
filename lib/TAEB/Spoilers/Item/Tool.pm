#!/usr/bin/env perl
package TAEB::Spoilers::Item::Tool;
use MooseX::Singleton;
extends 'TAEB::Spoilers::Item';

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
                plural => 'sacks',
            },
            'large box' => {
                cost => 8,
                weight => 350,
                charge => '',
                plural => 'large boxes',
            },
            'chest' => {
                cost => 16,
                weight => 600, charge => '',
                plural => 'chests',
            },
            'ice box' => {
                cost => 42,
                weight => 900,
                charge => '',
                plural => 'ice boxes',
            },
            'bag of holding' => {
                cost => 100,
                weight => 15,
                charge => '',
                appearance => 'bag',
                plural => 'bags of holding',
            },
            'bag of tricks' => {
                cost => 100,
                weight => 15,
                charge => 20,
                appearance => 'bag',
                plural => 'bags of tricks',
            },
            'oilskin sack' => {
                cost => 100,
                weight => 15,
                charge => '',
                appearance => 'bag',
                plural => 'oilskin sacks',
            },
            'credit card' => {
                cost => 10,
                weight => 1,
                charge => '',
                plural => 'credit cards',
            },
            'lock pick' => {
                cost => 20,
                weight => 4,
                charge => '',
                plural => 'lock picks',
            },
            'skeleton key' => {
                cost => 10,
                weight => 3,
                charge => '',
                appearance => 'key',
                plural => 'skeleton keys',
            },
            'tallow candle' => {
                cost => 10,
                weight => 2,
                charge => '',
                appearance => 'candle',
                plural => 'tallow candles',
            },
            'wax candle' => {
                cost => 20,
                weight => 2,
                charge => '',
                appearance => 'candle',
                plural => 'wax candles',
            },
            'brass lantern' => {
                cost => 12,
                weight => 30,
                charge => 1499,
                plural => 'brass lanterns',
            },
            'oil lamp' => {
                cost => 10,
                weight => 20,
                charge => 1499,
                appearance => 'lamp',
                plural => 'oil lamps',
            },
            'magic lamp' => {
                cost => 50,
                weight => 20,
                charge => '',
                appearance => 'lamp',
                plural => 'magic lamps',
            },
            'tin whistle' => {
                cost => 10,
                weight => 3,
                charge => '',
                appearance => 'whistle',
                plural => 'tin whistles',
            },
            'magic whistle' => {
                cost => 10,
                weight => 3,
                charge => '',
                appearance => 'whistle',
                plural => 'magic whistles',
            },
            'bugle' => {
                cost => 15,
                weight => 10,
                charge => '',
                plural => 'bugles',
            },
            'wooden flute' => {
                cost => 12,
                weight => 5,
                charge => '',
                appearance => 'flute',
                plural => 'wooden flutes',
            },
            'magic flute' => {
                cost => 36,
                weight => 5,
                charge => 8,
                appearance => 'flute',
                plural => 'magic flutes',
            },
            'tooled horn' => {
                cost => 15,
                weight => 18,
                charge => '',
                appearance => 'horn',
                plural => 'tooled horns',
            },
            'frost horn' => {
                cost => 50,
                weight => 18,
                charge => 8,
                appearance => 'horn',
                plural => 'frost horns',
            },
            'fire horn' => {
                cost => 50,
                weight => 18,
                charge => 8,
                appearance => 'horn',
                plural => 'fire horns',
            },
            'horn of plenty' => {
                cost => 50,
                weight => 18,
                charge => 20,
                appearance => 'horn',
                plural => 'horns of plenty',
            },
            'leather drum' => {
                cost => 25,
                weight => 25,
                charge => '',
                appearance => 'drum',
                plural => 'leather drums',
            },
            'drum of earthquake' => {
                cost => 25,
                weight => 25,
                charge => 8,
                appearance => 'drum',
                plural => 'drums of earthquake',
            },
            'wooden harp' => {
                cost => 50,
                weight => 30,
                charge => '',
                appearance => 'harp',
                plural => 'wooden harps',
            },
            'magic harp' => {
                cost => 50,
                weight => 30,
                charge => 8,
                appearance => 'harp',
                plural => 'magic harps',
            },
            'bell' => {
                cost => 50,
                weight => 30,
                charge => '',
                plural => 'bells',
            },
            'beartrap' => {
                cost => 60,
                weight => 200,
                charge => '',
                plural => 'beartraps',
            },
            'land mine' => {
                cost => 180,
                weight => 300,
                charge => '',
                appearance => 'land mine',
                plural => 'land mines',
            },
            'pick-axe' => {
                cost => 50,
                weight => 100,
                charge => '',
                plural => 'pick-axes',
            },
            'grappling hook' => {
                cost => 50,
                weight => 30,
                charge => '',
                appearance => 'iron hook',
                plural => 'grappling hooks',
            },
            'unicorn horn' => {
                cost => 100,
                weight => 20,
                charge => '',
                plural => 'unicorn horns',
            },
            'expensive camera' => {
                cost => 200,
                weight => 12,
                charge => 99,
                plural => 'expensive cameras',
            },
            'mirror' => {
                cost => 10,
                weight => 13,
                charge => '',
                appearance => 'looking glass',
                plural => 'mirrors',
            },
            'crystal ball' => {
                cost => 60,
                weight => 150,
                charge => 5,
                appearance => 'glass orb',
                plural => 'crystal balls',
            },
            'lenses' => {
                cost => 80,
                weight => 3,
                charge => '',
                plural => 'lenseses', # XXX: NetHack actually does this
            },
            'blindfold' => {
                cost => 20,
                weight => 2,
                charge => '',
                plural => 'blindfolds',
            },
            'towel' => {
                cost => 50,
                weight => 2,
                charge => '',
                plural => 'towels',
            },
            'saddle' => {
                cost => 150,
                weight => 200,
                charge => '',
                plural => 'saddles',
            },
            'leash' => {
                cost => 20,
                weight => 12,
                charge => '',
                plural => 'leashes',
            },
            'stethoscope' => {
                cost => 75,
                weight => 4,
                charge => '',
                plural => 'stethoscopes',
            },
            'tinning kit' => {
                cost => 30,
                weight => 100,
                charge => 99,
                plural => 'tinning kits',
            },
            'tin opener' => {
                cost => 30,
                weight => 4,
                charge => '',
                plural => 'tin openers',
            },
            'can of grease' => {
                cost => 20,
                weight => 15,
                charge => 25,
                plural => 'cans of grease',
            },
            'figurine' => {
                cost => 80,
                weight => 50,
                charge => '',
                plural => 'figurines',
            },
            'magic marker' => {
                cost => 50,
                weight => 2,
                charge => 99,
                plural => 'magic markers',
            },
        };

        # tag each tool with its name and appearance
        while (my ($name, $stats) = each %$tools) {
            $stats->{name} = $name;
            $stats->{appearance} = $name unless $stats->{appearance};
        }

        return $tools;
    },
);

has multi_identity_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [qw/lamp whistle flute drum harp figurine horn candle
                            bag/] },
);

has constant_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    lazy       => 1,
    default    => sub {
        my $self = shift;
        my $appearances = [];
        while (my ($item, $stats) = each %{ $self->list }) {
            next if grep { $_ eq $stats->{appearance} }
                         $self->multi_identity_appearances;
            push @$appearances, $stats->{appearance};
        }
        return $appearances;
    },
);

sub tool {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


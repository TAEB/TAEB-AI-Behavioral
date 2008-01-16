#!/usr/bin/env perl
package TAEB::Spoilers::Item::Food;
use MooseX::Singleton;
use TAEB::Spoilers::Monster; # for corpses
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $foods = {
            'meatball' => {
                cost => 5, weight => 1, nutrition => 5, time => 1,
                plural => 'meatballs',
            },
            'meat ring' => {
                cost => 5, weight => 1, nutrition => 5, time => 1,
                plural => 'meat rings',
            },
            'meat stick' => {
                cost => 5, weight => 1, nutrition => 5, time => 1,
                plural => 'meat sticks',
            },
            'tripe ration' => {
                cost => 15, weight => 10, nutrition => 200, time => 2, unsafe => 1,
                plural => 'tripe rations',
            },
            'huge chunk of meat' => {
                cost => 105, weight => 400, nutrition => 2000, time => 20,
                plural => 'huge chunks of meat',
            },
            'kelp frond' => {
                cost => 6, weight => 1, nutrition => 30, time => 1,
                plural => 'kelp fronds',
            },
            'eucalyptus leaf' => {
                cost => 6, weight => 1, nutrition => 30, time => 1,
                plural => 'eucalyptus leaves',
            },
            'clove of garlic' => {
                cost => 7, weight => 1, nutrition => 40, time => 1,
                plural => 'cloves of garlic',
            },
            'sprig of wolfsbane' => {
                cost => 7, weight => 1, nutrition => 40, time => 1,
                plural => 'sprigs of wolfsbane',
            },
            'apple' => {
                cost => 7, weight => 2, nutrition => 50, time => 1,
                plural => 'apples',
            },
            'carrot' => {
                cost => 7, weight => 2, nutrition => 50, time => 1,
                plural => 'carrots',
            },
            'pear' => {
                cost => 7, weight => 2, nutrition => 50, time => 1,
                plural => 'pears',
            },
            'banana' => {
                cost => 9, weight => 2, nutrition => 80, time => 1,
                plural => 'bananas',
            },
            'orange' => {
                cost => 9, weight => 2, nutrition => 80, time => 1,
                plural => 'oranges',
            },
            'melon' => {
                cost => 10, weight => 5, nutrition => 100, time => 1,
                plural => 'melons',
            },
            'slime mold' => {
                cost => 17, weight => 5, nutrition => 250, time => 1,
                plural => 'slime molds',
            },
            'fortune cookie' => {
                cost => 7, weight => 1, nutrition => 40, time => 1,
                plural => 'fortune cookies',
            },
            'candy bar' => {
                cost => 10, weight => 2, nutrition => 100, time => 1,
                plural => 'candy bars',
            },
            'cream pie' => {
                cost => 10, weight => 10, nutrition => 100, time => 1,
                plural => 'cream pies',
            },
            'lump of royal jelly' => {
                cost => 15, weight => 2, nutrition => 200, time => 1,
                plural => 'lumps of royal jelly',
            },
            'pancake' => {
                cost => 15, weight => 2, nutrition => 200, time => 2,
                plural => 'pancakes',
            },
            'C-ration' => {
                cost => 20, weight => 10, nutrition => 300, time => 1,
                plural => 'C-rations',
            },
            'K-ration' => {
                cost => 25, weight => 10, nutrition => 400, time => 1,
                plural => 'K-rations',
            },
            'cram ration' => {
                cost => 35, weight => 15, nutrition => 600, time => 3,
                plural => 'cram rations',
            },
            'food ration' => {
                cost => 45, weight => 20, nutrition => 800, time => 5,
                plural => 'food rations',
            },
            'lembas wafer' => {
                cost => 45, weight => 5, nutrition => 800, time => 2,
                plural => 'lembas wafers',
            },
        };

        # Collect monster corpses, tins, and eggs
        my $monsterlist = TAEB::Spoilers::Monster->list;
        while (my ($name, $stats) = each %$monsterlist) {
            $foods->{"$name corpse"} = $stats->{corpse};
            $foods->{"$name corpse"}->{corpse} = 1;
            $foods->{"$name corpse"}->{plural} = "$name corpses";

            my $tin_name = $name;
            $tin_name .= " meat"
                unless $stats->{corpse}->{vegetarian};
            $foods->{"tin of $tin_name"} = {
                appearance => "tin",
                plural => "tins of $tin_name",
            };

            if ($stats->{has_egg}) {
                $foods->{"$name egg"} = {
                    cost => 9, weight => 1,
                    nutrition => 80, time => 1, unsafe => 1,
                    appearance => "egg",
                    plural => "$name eggs",
                };
            }
        }

        # tag each food with its name and appearance
        while (my ($name, $stats) = each %$foods) {
            $stats->{name} = $name;
            $stats->{appearance} = $name unless $stats->{appearance};
        }

        return $foods;
    },
);

has constant_appearances => (
    is        => 'ro',
    isa       => 'ArrayRef',
    autoderef => 1,
    lazy      => 1,
    default   => sub {
        my $self = shift;
        my $appearances = [];
        while (my ($item, $stats) = each %{ $self->list }) {
            push @$appearances, $stats->appearance;
        }
        return $appearances;
    },
);

sub food {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

sub should_eat {
    my $self = shift;
    my $item = shift;
    my $food = $self->food($item);

    return 0 if !$food;
    return 0 if $food->{unsafe};
    return 0 if $food->{corpse} && $food->{name} !~ /lichen|lizard/; # :|
    return 1;
}

1;


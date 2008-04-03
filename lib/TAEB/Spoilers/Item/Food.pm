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
                base => 5, weight => 1, nutrition => 5, time => 1,
                plural => 'meatballs',
            },
            'meat ring' => {
                base => 5, weight => 1, nutrition => 5, time => 1,
                plural => 'meat rings',
            },
            'meat stick' => {
                base => 5, weight => 1, nutrition => 5, time => 1,
                plural => 'meat sticks',
            },
            'tripe ration' => {
                base => 15, weight => 10, nutrition => 200, time => 2, unsafe => 1,
                plural => 'tripe rations',
            },
            'huge chunk of meat' => {
                base => 105, weight => 400, nutrition => 2000, time => 20,
                plural => 'huge chunks of meat',
            },
            'kelp frond' => {
                base => 6, weight => 1, nutrition => 30, time => 1,
                plural => 'kelp fronds',
            },
            'eucalyptus leaf' => {
                base => 6, weight => 1, nutrition => 30, time => 1,
                plural => 'eucalyptus leaves',
            },
            'clove of garlic' => {
                base => 7, weight => 1, nutrition => 40, time => 1,
                plural => 'cloves of garlic',
            },
            'sprig of wolfsbane' => {
                base => 7, weight => 1, nutrition => 40, time => 1,
                plural => 'sprigs of wolfsbane',
            },
            'apple' => {
                base => 7, weight => 2, nutrition => 50, time => 1,
                plural => 'apples',
            },
            'carrot' => {
                base => 7, weight => 2, nutrition => 50, time => 1,
                plural => 'carrots',
            },
            'pear' => {
                base => 7, weight => 2, nutrition => 50, time => 1,
                plural => 'pears',
            },
            'banana' => {
                base => 9, weight => 2, nutrition => 80, time => 1,
                plural => 'bananas',
            },
            'orange' => {
                base => 9, weight => 2, nutrition => 80, time => 1,
                plural => 'oranges',
            },
            'melon' => {
                base => 10, weight => 5, nutrition => 100, time => 1,
                plural => 'melons',
            },
            'slime mold' => {
                base => 17, weight => 5, nutrition => 250, time => 1,
                plural => 'slime molds',
            },
            'fortune cookie' => {
                base => 7, weight => 1, nutrition => 40, time => 1,
                plural => 'fortune cookies',
            },
            'candy bar' => {
                base => 10, weight => 2, nutrition => 100, time => 1,
                plural => 'candy bars',
            },
            'cream pie' => {
                base => 10, weight => 10, nutrition => 100, time => 1,
                plural => 'cream pies',
            },
            'lump of royal jelly' => {
                base => 15, weight => 2, nutrition => 200, time => 1,
                plural => 'lumps of royal jelly',
            },
            'pancake' => {
                base => 15, weight => 2, nutrition => 200, time => 2,
                plural => 'pancakes',
            },
            'C-ration' => {
                base => 20, weight => 10, nutrition => 300, time => 1,
                plural => 'C-rations',
            },
            'K-ration' => {
                base => 25, weight => 10, nutrition => 400, time => 1,
                plural => 'K-rations',
            },
            'cram ration' => {
                base => 35, weight => 15, nutrition => 600, time => 3,
                plural => 'cram rations',
            },
            'food ration' => {
                base => 45, weight => 20, nutrition => 800, time => 5,
                plural => 'food rations',
            },
            'lembas wafer' => {
                base => 45, weight => 5, nutrition => 800, time => 2,
                plural => 'lembas wafers',
            },
            'empty tin' => {
                nutrition  => 0,
                plural     => 'empty tins',
                appearance => 'tin',
            },
            'tin of spinach' => {
                nutrition  => 800,
                plural     => 'tins of spinach',
                appearance => 'tin',
            },
        };

        # Collect monster corpses, tins, and eggs
        my $monsterlist = TAEB::Spoilers::Monster->list;
        for my $name (keys %$monsterlist) {
            my $stats = $monsterlist->{$name};
            $foods->{"$name corpse"}             = $stats->{corpse};
            $foods->{"$name corpse"}{corpse}     = 1;
            $foods->{"$name corpse"}{plural}     = "$name corpses";

            my $tin_name = $name;
            $tin_name .= " meat"
                unless $stats->{corpse}->{vegetarian};
            $foods->{"tin of $tin_name"} = {
                appearance => "tin",
                plural => "tins of $tin_name",
            };

            if ($stats->{has_egg}) {
                $foods->{"$name egg"} = {
                    base => 9, weight => 1,
                    nutrition => 80, time => 1, unsafe => 1,
                    appearance => "egg",
                    plural => "$name eggs",
                };
            }
        }

        # tag each food with its name and appearance
        for my $name (keys %$foods) {
            my $stats = $foods->{$name};
            $stats->{name} = $name;
            $stats->{appearance} = $name unless $stats->{appearance};
        }

        return $foods;
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
        while (my ($item, $stats) = each %{ $self->list }) {
            next if $item =~ /\b(?:tin|egg)\b/;
            $appearances->{$stats->{appearance}} = $stats->{name}
        }
        return $appearances;
    },
);

# XXX: not entirely correct, since identifying these doesn't make future
# instances of that identity identified
has multi_identity_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    lazy       => 1,
    default    => sub {
        [qw/tin egg/]
    },
);

sub food {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return unless $item;
    return $self->list->{$item};
}

sub pluralize_unided {
    my $self = shift;
    my $item = shift;

    $item =~ s/\b(tin|egg)\b/$1s/;
    return $item;
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

no Moose;

1;


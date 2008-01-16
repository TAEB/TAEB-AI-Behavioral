#!/usr/bin/env perl
package TAEB::Spoilers::Item::Armor;
use MooseX::Singleton;
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $armor = {
            'Mitre of Holiness' => {
                artifact   => 1,
                cost       => 2000,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
            },
            'Hawaiian shirt' => {
                cost       => 3,
                weight     => 5,
                ac         => 0,
                material   => 'cloth',
            },
            'T-shirt' => {
                cost       => 2,
                weight     => 5,
                ac         => 0,
                material   => 'cloth',
            },
            'leather jacket' => {
                cost       => 10,
                weight     => 30,
                ac         => 1,
                material   => 'leather',
            },
            'leather armor' => {
                cost       => 5,
                weight     => 150,
                ac         => 2,
                material   => 'leather',
            },
            'orcish ring mail' => {
                cost       => 80,
                weight     => 250,
                ac         => 2,
                material   => 'iron',
                mc         => 1,
                appearance => 'crude ring mail',
            },
            'studded leather armor' => {
                cost       => 15,
                weight     => 200,
                ac         => 3,
                material   => 'leather',
                mc         => 1,
            },
            'ring mail' => {
                cost       => 100,
                weight     => 250,
                ac         => 3,
                material   => 'iron',
            },
            'scale mail' => {
                cost       => 45,
                weight     => 250,
                ac         => 4,
                material   => 'iron',
            },
            'orcish chain mail' => {
                cost       => 75,
                weight     => 300,
                ac         => 4,
                material   => 'iron',
                mc         => 1,
                appearance => 'crude chain mail',
            },
            'chain mail' => {
                cost       => 75,
                weight     => 300,
                ac         => 5,
                material   => 'iron',
                mc         => 1,
            },
            'elven mithril coat' => {
                cost       => 240,
                weight     => 150,
                ac         => 5,
                material   => 'mithril',
                mc         => 3,
            },
            'splint mail' => {
                cost       => 80,
                weight     => 400,
                ac         => 6,
                material   => 'iron',
                mc         => 1,
            },
            'banded mail' => {
                cost       => 90,
                weight     => 350,
                ac         => 6,
                material   => 'iron',
            },
            'dwarvish mithril coat' => {
                cost       => 240,
                weight     => 150,
                ac         => 6,
                material   => 'mithril',
                mc         => 3,
            },
            'bronze plate mail' => {
                cost       => 400,
                weight     => 450,
                ac         => 6,
                material   => 'copper',
            },
            'plate mail' => {
                cost       => 600,
                weight     => 450,
                ac         => 7,
                material   => 'iron',
                mc         => 2,
            },
            'crystal plate mail' => {
                cost       => 820,
                weight     => 450,
                ac         => 7,
                material   => 'glass',
                mc         => 2,
            },
            'red dragon scales' => {
                cost       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'white dragon scales' => {
                cost       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'orange dragon scales' => {
                cost       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'blue dragon scales' => {
                cost       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'green dragon scales' => {
                cost       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'yellow dragon scales' => {
                cost       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'black dragon scales' => {
                cost       => 700,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'silver dragon scales' => {
                cost       => 700,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'gray dragon scales' => {
                cost       => 700,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'red dragon scale mail' => {
                cost       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'white dragon scale mail' => {
                cost       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'orange dragon scale mail:' => {
                cost       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'blue dragon scale mail' => {
                cost       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'green dragon scale mail' => {
                cost       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'yellow dragon scale mail' => {
                cost       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'black dragon scale mail' => {
                cost       => 1200,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'silver dragon scale mail' => {
                cost       => 1200,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'gray dragon scale mail' => {
                cost       => 1200,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'mummy wrapping' => {
                cost       => 2,
                weight     => 3,
                ac         => 0,
                material   => 'cloth',
                mc         => 1,
            },
            'orcish cloak' => {
                cost       => 40,
                weight     => 10,
                ac         => 0,
                material   => 'cloth',
                mc         => 2,
                appearance => 'coarse mantelet',
            },
            'dwarvish cloak' => {
                cost       => 50,
                weight     => 10,
                ac         => 0,
                material   => 'cloth',
                mc         => 2,
                appearance => 'hooded cloak',
            },
            'leather cloak' => {
                cost       => 40,
                weight     => 15,
                ac         => 1,
                material   => 'leather',
                mc         => 1,
            },
            'cloak of displacement' => {
                cost       => 50,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 2,
            },
            'oilskin cloak' => {
                cost       => 50,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 3,
                appearance => 'slippery cloak',
            },
            'alchemy smock' => {
                cost       => 50,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 1,
                appearance => 'apron',
            },
            'cloak of invisibility' => {
                cost       => 60,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 2,
            },
            'cloak of magic resistance' => {
                cost       => 60,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 3,
            },
            'elven cloak' => {
                cost       => 60,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 3,
                appearance => 'faded pall',
            },
            'robe' => {
                cost       => 50,
                weight     => 15,
                ac         => 2,
                material   => 'cloth',
                mc         => 3,
            },
            'cloak of protection' => {
                cost       => 50,
                weight     => 10,
                ac         => 3,
                material   => 'cloth',
                mc         => 3,
            },
            'fedora' => {
                cost       => 1,
                weight     => 3,
                ac         => 0,
                material   => 'cloth',
            },
            'dunce cap' => {
                cost       => 1,
                weight     => 4,
                ac         => 0,
                material   => 'cloth',
                appearance => 'conical hat',
            },
            'cornuthaum' => {
                cost       => 80,
                weight     => 4,
                ac         => 0,
                material   => 'cloth',
                mc         => 2,
                appearance => 'conical hat',
            },
            'dented pot' => {
                cost       => 8,
                weight     => 10,
                ac         => 1,
                material   => 'iron',
            },
            'elven leather helm' => {
                cost       => 8,
                weight     => 3,
                ac         => 1,
                material   => 'leather',
                appearance => 'leather hat',
            },
            'helmet' => {
                cost       => 10,
                weight     => 30,
                ac         => 1,
                material   => 'iron',
            },
            'orcish helm' => {
                cost       => 10,
                weight     => 30,
                ac         => 1,
                material   => 'iron',
                appearance => 'iron skull cap',
            },
            'helm of brilliance' => {
                cost       => 50,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
            },
            'helm of opposite alignment' => {
                cost       => 50,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
            },
            'helm of telepathy' => {
                cost       => 50,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
            },
            'dwarvish iron helm' => {
                cost       => 20,
                weight     => 40,
                ac         => 2,
                material   => 'iron',
                appearance => 'hard hat',
            },
            'leather gloves' => {
                cost       => 8,
                weight     => 10,
                ac         => 1,
                material   => 'leather',
            },
            'gauntlets of dexterity' => {
                cost       => 50,
                weight     => 10,
                ac         => 1,
                material   => 'leather',
            },
            'gauntlets of fumbling' => {
                cost       => 50,
                weight     => 10,
                ac         => 1,
                material   => 'leather',
            },
            'gauntlets of power' => {
                cost       => 50,
                weight     => 30,
                ac         => 1,
                material   => 'iron',
            },
            'small shield' => {
                cost       => 3,
                weight     => 30,
                ac         => 1,
                material   => 'wood',
            },
            'orcish shield' => {
                cost       => 7,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
                appearance => 'red-eyed shield',
            },
            'Uruk-hai shield' => {
                cost       => 7,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
                appearance => 'white-handed shield',
            },
            'elven shield' => {
                cost       => 7,
                weight     => 40,
                ac         => 2,
                material   => 'wood',
                appearance => 'blue and green shield',
            },
            'dwarvish roundshield' => {
                cost       => 10,
                weight     => 100,
                ac         => 2,
                material   => 'iron',
                appearance => 'large round shield',
            },
            'large shield' => {
                cost       => 10,
                weight     => 100,
                ac         => 2,
                material   => 'iron',
            },
            'shield of reflection' => {
                cost       => 50,
                weight     => 50,
                ac         => 2,
                material   => 'silver',
                appearance => 'polished silver shield',
            },
            'low boots' => {
                cost       => 8,
                weight     => 10,
                ac         => 1,
                material   => 'leather',
                appearance => 'walking shoes',
            },
            'elven boots' => {
                cost       => 8,
                weight     => 15,
                ac         => 1,
                material   => 'leather',
            },
            'kicking boots' => {
                cost       => 8,
                weight     => 15,
                ac         => 1,
                material   => 'iron',
            },
            'fumble boots' => {
                cost       => 30,
                weight     => 20,
                ac         => 1,
                material   => 'leather',
            },
            'levitation boots' => {
                cost       => 30,
                weight     => 15,
                ac         => 1,
                material   => 'leather',
            },
            'jumping boots' => {
                cost       => 50,
                weight     => 20,
                ac         => 1,
                material   => 'leather',
            },
            'speed boots' => {
                cost       => 50,
                weight     => 20,
                ac         => 1,
                material   => 'leather',
            },
            'water walking boots' => {
                cost       => 50,
                weight     => 20,
                ac         => 1,
                material   => 'leather',
            },
            'high boots' => {
                cost       => 12,
                weight     => 20,
                ac         => 2,
                material   => 'leather',
                appearance => 'jackboots',
            },
            'iron shoes' => {
                cost       => 16,
                weight     => 50,
                ac         => 2,
                material   => 'iron',
                appearance => 'hard shoes',
            },
        };

        # tag each armor with its name and appearance
        while (my ($name, $stats) = each %$armor) {
            $stats->{name} = $name;
            $stats->{appearance} = $name unless $stats->{appearance};
        }

        return $armor;
    },
);

has randomized_appearances => (
    is        => 'ro',
    isa       => 'ArrayRef',
    autoderef => 1,
    default   => sub {
        my @helms = map { "$_ helmet" } qw/plumed etched crested visored/;
        my @cloaks = ('tattered cape', 'opera cloak', 'ornamental cope',
                      'piece of cloth');
        my @gloves = map { "$_ gloves" } qw/old padded riding fencing/;
        my @boots = map { "$_ boots" } qw/combat jungle hiking mud buckled
                                          riding snow/;
        return [@helms, @cloaks, @gloves, @boots];
    },
);

has multi_identity_appearances => (
    is        => 'ro',
    isa       => 'ArrayRef',
    autoderef => 1,
    default   => sub { ['conical hat'] },
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
            next if !defined $stats->appearance ||
                    grep { $_ eq $stats->appearance }
                         $self->multi_identity_appearances;
            push @$appearances, $stats->appearance;
        }
        return $appearances;
    },
);

sub armor {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;


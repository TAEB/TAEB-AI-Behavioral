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
                base       => 2000,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
            },
            'Hawaiian shirt' => {
                base       => 3,
                weight     => 5,
                ac         => 0,
                material   => 'cloth',
            },
            'T-shirt' => {
                base       => 2,
                weight     => 5,
                ac         => 0,
                material   => 'cloth',
            },
            'leather jacket' => {
                base       => 10,
                weight     => 30,
                ac         => 1,
                material   => 'leather',
            },
            'leather armor' => {
                base       => 5,
                weight     => 150,
                ac         => 2,
                material   => 'leather',
            },
            'orcish ring mail' => {
                base       => 80,
                weight     => 250,
                ac         => 2,
                material   => 'iron',
                mc         => 1,
                appearance => 'crude ring mail',
            },
            'studded leather armor' => {
                base       => 15,
                weight     => 200,
                ac         => 3,
                material   => 'leather',
                mc         => 1,
            },
            'ring mail' => {
                base       => 100,
                weight     => 250,
                ac         => 3,
                material   => 'iron',
            },
            'scale mail' => {
                base       => 45,
                weight     => 250,
                ac         => 4,
                material   => 'iron',
            },
            'orcish chain mail' => {
                base       => 75,
                weight     => 300,
                ac         => 4,
                material   => 'iron',
                mc         => 1,
                appearance => 'crude chain mail',
            },
            'chain mail' => {
                base       => 75,
                weight     => 300,
                ac         => 5,
                material   => 'iron',
                mc         => 1,
            },
            'elven mithril-coat' => {
                base       => 240,
                weight     => 150,
                ac         => 5,
                material   => 'mithril',
                mc         => 3,
            },
            'splint mail' => {
                base       => 80,
                weight     => 400,
                ac         => 6,
                material   => 'iron',
                mc         => 1,
            },
            'banded mail' => {
                base       => 90,
                weight     => 350,
                ac         => 6,
                material   => 'iron',
            },
            'dwarvish mithril-coat' => {
                base       => 240,
                weight     => 150,
                ac         => 6,
                material   => 'mithril',
                mc         => 3,
            },
            'bronze plate mail' => {
                base       => 400,
                weight     => 450,
                ac         => 6,
                material   => 'copper',
            },
            'plate mail' => {
                base       => 600,
                weight     => 450,
                ac         => 7,
                material   => 'iron',
                mc         => 2,
            },
            'crystal plate mail' => {
                base       => 820,
                weight     => 450,
                ac         => 7,
                material   => 'glass',
                mc         => 2,
            },
            'red dragon scales' => {
                base       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'white dragon scales' => {
                base       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'orange dragon scales' => {
                base       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'blue dragon scales' => {
                base       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'green dragon scales' => {
                base       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'yellow dragon scales' => {
                base       => 500,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'black dragon scales' => {
                base       => 700,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'silver dragon scales' => {
                base       => 700,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'gray dragon scales' => {
                base       => 700,
                weight     => 40,
                ac         => 3,
                material   => 'dragon hide',
            },
            'red dragon scale mail' => {
                base       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'white dragon scale mail' => {
                base       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'orange dragon scale mail' => {
                base       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'blue dragon scale mail' => {
                base       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'green dragon scale mail' => {
                base       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'yellow dragon scale mail' => {
                base       => 900,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'black dragon scale mail' => {
                base       => 1200,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'silver dragon scale mail' => {
                base       => 1200,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'gray dragon scale mail' => {
                base       => 1200,
                weight     => 40,
                ac         => 9,
                material   => 'dragon hide',
            },
            'mummy wrapping' => {
                base       => 2,
                weight     => 3,
                ac         => 0,
                material   => 'cloth',
                mc         => 1,
            },
            'orcish cloak' => {
                base       => 40,
                weight     => 10,
                ac         => 0,
                material   => 'cloth',
                mc         => 2,
                appearance => 'coarse mantelet',
            },
            'dwarvish cloak' => {
                base       => 50,
                weight     => 10,
                ac         => 0,
                material   => 'cloth',
                mc         => 2,
                appearance => 'hooded cloak',
            },
            'leather cloak' => {
                base       => 40,
                weight     => 15,
                ac         => 1,
                material   => 'leather',
                mc         => 1,
            },
            'cloak of displacement' => {
                base       => 50,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 2,
            },
            'oilskin cloak' => {
                base       => 50,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 3,
                appearance => 'slippery cloak',
            },
            'alchemy smock' => {
                base       => 50,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 1,
                appearance => 'apron',
            },
            'cloak of invisibility' => {
                base       => 60,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 2,
            },
            'cloak of magic resistance' => {
                base       => 60,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 3,
            },
            'elven cloak' => {
                base       => 60,
                weight     => 10,
                ac         => 1,
                material   => 'cloth',
                mc         => 3,
                appearance => 'faded pall',
            },
            'robe' => {
                base       => 50,
                weight     => 15,
                ac         => 2,
                material   => 'cloth',
                mc         => 3,
            },
            'cloak of protection' => {
                base       => 50,
                weight     => 10,
                ac         => 3,
                material   => 'cloth',
                mc         => 3,
            },
            'fedora' => {
                base       => 1,
                weight     => 3,
                ac         => 0,
                material   => 'cloth',
            },
            'dunce cap' => {
                base       => 1,
                weight     => 4,
                ac         => 0,
                material   => 'cloth',
                appearance => 'conical hat',
            },
            'cornuthaum' => {
                base       => 80,
                weight     => 4,
                ac         => 0,
                material   => 'cloth',
                mc         => 2,
                appearance => 'conical hat',
            },
            'dented pot' => {
                base       => 8,
                weight     => 10,
                ac         => 1,
                material   => 'iron',
            },
            'elven leather helm' => {
                base       => 8,
                weight     => 3,
                ac         => 1,
                material   => 'leather',
                appearance => 'leather hat',
            },
            'helmet' => {
                base       => 10,
                weight     => 30,
                ac         => 1,
                material   => 'iron',
            },
            'orcish helm' => {
                base       => 10,
                weight     => 30,
                ac         => 1,
                material   => 'iron',
                appearance => 'iron skull cap',
            },
            'helm of brilliance' => {
                base       => 50,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
            },
            'helm of opposite alignment' => {
                base       => 50,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
            },
            'helm of telepathy' => {
                base       => 50,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
            },
            'dwarvish iron helm' => {
                base       => 20,
                weight     => 40,
                ac         => 2,
                material   => 'iron',
                appearance => 'hard hat',
            },
            'leather gloves' => {
                base       => 8,
                weight     => 10,
                ac         => 1,
                material   => 'leather',
            },
            'gauntlets of dexterity' => {
                base       => 50,
                weight     => 10,
                ac         => 1,
                material   => 'leather',
            },
            'gauntlets of fumbling' => {
                base       => 50,
                weight     => 10,
                ac         => 1,
                material   => 'leather',
            },
            'gauntlets of power' => {
                base       => 50,
                weight     => 30,
                ac         => 1,
                material   => 'iron',
            },
            'small shield' => {
                base       => 3,
                weight     => 30,
                ac         => 1,
                material   => 'wood',
            },
            'orcish shield' => {
                base       => 7,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
                appearance => 'red-eyed shield',
            },
            'Uruk-hai shield' => {
                base       => 7,
                weight     => 50,
                ac         => 1,
                material   => 'iron',
                appearance => 'white-handed shield',
            },
            'elven shield' => {
                base       => 7,
                weight     => 40,
                ac         => 2,
                material   => 'wood',
                appearance => 'blue and green shield',
            },
            'dwarvish roundshield' => {
                base       => 10,
                weight     => 100,
                ac         => 2,
                material   => 'iron',
                appearance => 'large round shield',
            },
            'large shield' => {
                base       => 10,
                weight     => 100,
                ac         => 2,
                material   => 'iron',
            },
            'shield of reflection' => {
                base       => 50,
                weight     => 50,
                ac         => 2,
                material   => 'silver',
                appearance => 'polished silver shield',
            },
            'low boots' => {
                base       => 8,
                weight     => 10,
                ac         => 1,
                material   => 'leather',
                appearance => 'walking shoes',
            },
            'elven boots' => {
                base       => 8,
                weight     => 15,
                ac         => 1,
                material   => 'leather',
            },
            'kicking boots' => {
                base       => 8,
                weight     => 15,
                ac         => 1,
                material   => 'iron',
            },
            'fumble boots' => {
                base       => 30,
                weight     => 20,
                ac         => 1,
                material   => 'leather',
            },
            'levitation boots' => {
                base       => 30,
                weight     => 15,
                ac         => 1,
                material   => 'leather',
            },
            'jumping boots' => {
                base       => 50,
                weight     => 20,
                ac         => 1,
                material   => 'leather',
            },
            'speed boots' => {
                base       => 50,
                weight     => 20,
                ac         => 1,
                material   => 'leather',
            },
            'water walking boots' => {
                base       => 50,
                weight     => 20,
                ac         => 1,
                material   => 'leather',
            },
            'high boots' => {
                base       => 12,
                weight     => 20,
                ac         => 2,
                material   => 'leather',
                appearance => 'jackboots',
            },
            'iron shoes' => {
                base       => 16,
                weight     => 50,
                ac         => 2,
                material   => 'iron',
                appearance => 'hard shoes',
            },
        };

        # tag each armor with its name and appearance
        for my $name (keys %$armor) {
            my $stats = $armor->{$name};
            $stats->{name} = $name;
            $stats->{appearance} = $name unless $stats->{appearance};
        }

        return $armor;
    },
);

has randomized_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
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
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { ['conical hat'] },
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
            next if !defined $stats->{appearance} ||
                    grep { $_ eq $stats->{appearance} }
                         $self->multi_identity_appearances;
            $appearances->{$stats->{appearance}} = $stats->{name}
        }
        return $appearances;
    },
);

sub armor {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return unless $item;
    return $self->list->{$item};
}

no Moose;

1;


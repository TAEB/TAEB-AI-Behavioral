#!/usr/bin/env perl
package TAEB::Spoilers::Item;
use MooseX::Singleton;
use List::MoreUtils 'any';

use TAEB::Spoilers::Item::Armor;
use TAEB::Spoilers::Item::Artifact;
use TAEB::Spoilers::Item::Food;
use TAEB::Spoilers::Item::Potion;
use TAEB::Spoilers::Item::Scroll;
use TAEB::Spoilers::Item::Spellbook;
use TAEB::Spoilers::Item::Tool;
use TAEB::Spoilers::Item::Wand;
use TAEB::Spoilers::Item::Weapon;
use TAEB::Spoilers::Item::Amulet;
use TAEB::Spoilers::Item::Ring;
use TAEB::Spoilers::Item::Wand;
use TAEB::Spoilers::Item::Gem;
use TAEB::Spoilers::Item::Other;

has types => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    default    => sub { [qw/Weapon Armor Potion Scroll Spellbook Tool Food
                            Amulet Ring Wand Gem Other/] },
    auto_deref => 1,
);

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $items = {};

        for my $type ($self->types) {
            my $list = "TAEB::Spoilers::Item::$type"->list;
            while (my ($name, $stats) = each %$list) {
                $items->{$name} = lc $type;
                $items->{$stats->{appearance}} = lc $type
                    if defined $stats->{appearance};
            }
            for my $attr (qw/randomized_appearances
                             multi_identity_appearances/) {
                if ("TAEB::Spoilers::Item::$type"->can($attr)) {
                    for my $name (@{"TAEB::Spoilers::Item::$type"->$attr}) {
                        $items->{$name} = lc $type;
                    }
                }
            }
            if ("TAEB::Spoilers::Item::$type"->can('constant_appearances')) {
                for my $name (keys %{"TAEB::Spoilers::Item::$type"->constant_appearances}) {
                    $items->{$name} = lc $type;
                }
            }
        }

        return $items;
    },
);

has plural_of_list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my %plural_of;
        my %exempt = map { $_ => 1 } qw/Armor Ring Wand Spellbook/;

        for my $type ($self->types) {
            next if $exempt{$type};

            my $list = "TAEB::Spoilers::Item::$type"->list;
            while (my ($name, $stats) = each %$list) {
                # no_plural or artifact ignore
                $stats->{no_plural} || $stats->{artifact}
                    or $plural_of{$name} = $stats->{plural}
                        or do {
                            # avoid spurious undef => whatever warnings
                            delete $plural_of{$name};

                            warn "No plural for $type '$name'.";
                        };
            }
        }

        return \%plural_of;
    },
);

has singular_of_list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return { reverse %{ $self->plural_of_list } };
    },
);

has english_of_list => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        my %japanese_to_english = (
            "wakizashi"       => "short sword",
            "ninja-to"        => "broadsword",
            "nunchaku"        => "flail",
            "naginata"        => "glaive",
            "osaku"           => "lock pick",
            "koto"            => "wooden harp",
            "shito"           => "knife",
            "tanko"           => "plate mail",
            "kabuto"          => "helmet",
            "yugake"          => "leather gloves",
            "gunyoki"         => "food ration",
            "potion of sake"  => "potion of booze",
            "potions of sake" => "potions of booze",
        );
        return \%japanese_to_english;
    },
);

has japanese_of_list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return { reverse %{ $self->english_of_list } };
    },
);

has all_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    lazy       => 1,
    auto_deref => 1,
    default    => sub {
        my $self = shift;
        my @random = $self->randomized_appearances
            if $self->can('randomized_appearances');
        my @constant = keys %{ $self->constant_appearances }
            if $self->can('constant_appearances');
        my @multi = $self->multi_identity_appearances
            if $self->can('multi_identity_appearances');
        return [@random, @constant, @multi];
    },
);

has all_identities => (
    is         => 'ro',
    isa        => 'ArrayRef',
    lazy       => 1,
    auto_deref => 1,
    default    => sub {
        my $self = shift;
        return [keys %{ $self->list }];
    },
);

sub try_normalize_class {
    my $self = shift;
    my $item = shift;

    # special case: we pretend it's amulet of Amulet of Yendor
    return if $item =~ /Amulet of Yendor/;

    if (my ($class, $kind) = $item =~ /^(.*?) of (.*)$/) {
        $class = lc $class;
        $class =~ s/s$//;
        return ($class, $kind) if any { $class eq lc } $self->types;
    }

    return;
}

sub type_to_class {
    my $self = shift;
    my $item = shift;

    if (my ($class) = $self->try_normalize_class($item)) {
        return $class;
    }

    return $self->list->{$item};
}

sub normalize {
    my $self = shift;
    my $item = shift;

    $item = TAEB::Spoilers::Item->english_of_list->{$item} || $item;
    return $self->singularize($item);
}

sub singularize {
    my $self = shift;
    my $item = shift;

    if (my ($class, $kind) = $self->try_normalize_class($item)) {
        return "$class of $kind";
    }

    return $self->singular_of_list->{$item} || $item;
}

sub pluralize {
    my $self = shift;
    my $item = shift;

    if (my ($class, $kind) = $self->try_normalize_class($item)) {
        return "${class}s of $kind";
    }

    return $self->plural_of_list->{$item} || $item;
}

1;


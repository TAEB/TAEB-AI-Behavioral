#!/usr/bin/env perl
package TAEB::Spoilers::Item;
use MooseX::Singleton;

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

has types => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    default    => sub { [qw/Weapon Armor Potion Scroll Spellbook Tool Food
                            Amulet Ring Wand Gem/] },
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
            if ("TAEB::Spoilers::Item::$type"->can('randomized_appearances')) {
                for my $name (@{"TAEB::Spoilers::Item::$type"->randomized_appearances}) {
                    $items->{$name} = lc $type;
                }
            }
        }

        return $items;
    },
);

has plural_of => (
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

has singular_of => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return { reverse %{ $self->plural_of } };
    },
);

has all_appearances => (
    is        => 'ro',
    isa       => 'ArrayRef',
    lazy      => 1,
    autoderef => 1,
    default   => sub {
        my $self = shift;
        my @random = $self->randomized_appearances
            if $self->can('randomized_appearances');
        my @constant = $self->constant_appearances
            if $self->can('constant_appearances');
        my @multi = $self->multi_identity_appearances
            if $self->can('multi_identity_appearances');
        return [@random, @constant, @multi];
    },
);

has all_identities => (
    is        => 'ro',
    isa       => 'ArrayRef',
    lazy      => 1,
    autoderef => 1,
    default   => sub {
        my $self = shift;
        return [keys %{ $self->list }];
    },
);

sub type_to_class {
    my $self = shift;
    my $item = shift;

    return $self->list->{$item};
}

1;


#!/usr/bin/env perl
package TAEB::Knowledge::Item;
use MooseX::Singleton;

use TAEB::Knowledge::Item::Food;
use TAEB::Knowledge::Item::Weapon;
use TAEB::Knowledge::Item::Tool;
use TAEB::Knowledge::Item::Artifact;
use TAEB::Knowledge::Item::Armor;

has types => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    default    => sub { [qw/Weapon Armor Tool Food/] },
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
            my $list = "TAEB::Knowledge::Item::$type"->list;
            while (my ($name, $stats) = each %$list) {
                $items->{$name} = lc $type;
                $items->{$stats->{appearance}} = lc $type;
            }
        }

        return $items;
    },
);

sub type_to_class {
    my $self = shift;
    my $item = shift;

    return $self->list->{$item};
}

sub canonicalize_item {
    my $self = shift;
    my $item = shift;

    my @words = qw(the an a greased blessed cursed uncursed);
    my @regex = (
        qr/[+-]?\d+/,               # enchantment, quantity
        qr/\b(?:fire|rust)proof\b/,
        qr/\([^)]+\)/,              # (being warn), (lit), etc
    );

    $item =~ s/\b$_\b//ig for @words;
    $item =~ s/$_//g      for @regex;

    # extra space bad
    $item =~ s/\s+/ /g;
    $item =~ s/^ //;
    $item =~ s/ $//;

    # try to turn plurals into singular
    $item =~ s/s$//;

    return $item;
}

1;


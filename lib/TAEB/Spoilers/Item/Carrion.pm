#!/usr/bin/env perl
package TAEB::Spoilers::Item::Carrion;
use MooseX::Singleton;
use TAEB::Spoilers::Monster;
extends 'TAEB::Spoilers::Item::Food';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        # Collect monster corpses, tins, and eggs
        my $foods = {};
        my $monsterlist = TAEB::Spoilers::Monster->list;
        for my $name (keys %$monsterlist) {
            my $stats = $monsterlist->{$name};
            $foods->{"$name corpse"}             = $stats->{corpse};
            $foods->{"$name corpse"}{corpse}     = 1;
            $foods->{"$name corpse"}{plural}     = "$name corpses";
        }

        # tag each food with its name and appearance
        for my $name (keys %$foods) {
            my $stats = $foods->{$name};
            $stats->{name} = $name;
            $stats->{appearance} = $name;
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
            $appearances->{$item} = $item;
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
        []
    },
);

sub carrion {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return unless $item;
    return $self->list->{$item};
}

sub should_eat {
    my $self = shift;
    my $item = shift;
    my $food = $self->carrion($item);

    return 0 if !$food;
    return 0 if $food->{name} !~ /lichen|lizard/; # :|
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::World::Spells;
use Moose;
extends 'TAEB::World::Inventory';

my @slots = 'a' .. 'z', 'A' .. 'Z';

has _spells => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef[TAEB::Knowledge::Spell]',
    default   => sub { {} },
    provides  => {
        get    => 'get',
        set    => 'set',
        values => 'spells',
        keys   => 'slots',
        empty  => 'has_spells',
    },
);

sub learn {
    my $self = shift;
    my $name = shift;

    my $spell = TAEB::Knowledge::Spell->new(name => $name);
    my $new_slot = $slots[ $self->slots ];

    $self->set($new_slot => $spell);
}

sub castable_spells {
    my $self = shift;
    return grep { $_->castable } $self->spells;
}

sub forgotten_spells {
    my $self = shift;
    return grep { $_->forgotten } $self->spells;
}

1;


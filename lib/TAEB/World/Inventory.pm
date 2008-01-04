#!/usr/bin/env perl
package TAEB::World::Inventory;
use Moose;
use List::Util 'first';

has inventory => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef[TAEB::World::Item]',
    default   => sub { {} },
    provides  => {
        get    => 'get_item',
        set    => 'set_item',
        delete => 'remove_item',
        values => 'items',
    },
);

sub find_item {
    my $self = shift;
    my $item = shift;

    return first { $_->matches($item) } $self->items;
}

1;


#!/usr/bin/env perl
package TAEB::World::Inventory;
use Moose;

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

1;


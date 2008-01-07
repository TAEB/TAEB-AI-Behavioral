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

=head2 update Char, Item

This will update TAEB's inventory with the given item in the given slot.

This method will upgrade strings to TAEB::World::Item objects, but that
behavior should disappear.

=cut

sub update {
    my $self = shift;
    my $slot = shift;
    my $item = shift;

    # XXX update logic should be elsewhere. later.
    if (!ref($item)) {
        $item = TAEB::World::Item->new(appearance => $item);
    }

    $item->slot($slot);
    $self->set_item($slot => $item);
}

1;


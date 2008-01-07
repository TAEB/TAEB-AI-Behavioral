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
        get    => 'get',
        set    => 'set',
        delete => 'remove',
        values => 'items',
    },
);

sub find {
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

    TAEB->debug(
        sprintf "Inventory: slot '%s' has item '%s'.",
            $item->slot,
            $item->appearance,
    );

    $self->set($slot => $item);
}

=head2 decrease_quantity Str[, Int]

This will decrease the quantity of items in the given slot. Such as when you
quaff a potion, or throw a dagger. The optional argument is how many of these
items you just lost.

=cut

sub decrease_quantity {
    my $self     = shift;
    my $slot     = shift;
    my $quantity = shift || 1;

    # XXX: we don't do quantity tracking yet
    $self->remove($slot);
}

1;


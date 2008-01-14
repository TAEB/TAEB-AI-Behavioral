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
    my $matcher = shift;

    # pass in a coderef? return the first for which the coderef is true
    if (ref($matcher) eq 'CODE') {
        return first { $matcher->($_) } $self->items;
    }

    # pass in a string? assume it's a key => value dealy
    my $value = shift;
    return first {  $_->$matcher eq $value } $self->items;
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
        $item = TAEB::World::Item->new_item($item);
    }

    $item->slot($slot);

    TAEB->debug(
        sprintf "Inventory: slot '%s' has item '%s'.",
            $item->slot,
            $item->raw,
    );

    $self->set($slot => $item);
}

=head2 decrease_quantity Str[, Int]

This will decrease the quantity of items in the given slot. Such as when you
quaff a potion, or throw a dagger. The optional argument is how many of these
items you just lost. Returns the quantity remaining of that item.

=cut

sub decrease_quantity {
    my $self     = shift;
    my $slot     = shift;
    my $quantity = shift || 1;

    my $item = $self->get($slot);
    my $old_quantity = $item->quantity;
    my $new_quantity = $old_quantity - $quantity;

    if ($new_quantity < 0) {
        TAEB->error("Decreased $item from $old_quantity to $new_quantity");
        $new_quantity = 0;
    }

    if ($new_quantity == 0) {
        $self->remove($slot);
        return 0;
    }

    $item->quantity($new_quantity);

    return $new_quantity;
}

1;


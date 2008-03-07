#!/usr/bin/env perl
package TAEB::World::Inventory;
use Moose;
use List::Util 'first';

use overload
    q{""} => sub {
        shift->debug_display;
    };

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
        keys   => 'slots',
        empty  => 'has_items',
    },
);

sub find {
    my $self = shift;
    my $matcher = shift;

    # pass in a coderef? return the first for which the coderef is true
    if (ref($matcher) eq 'CODE') {
        return first { $matcher->($_) } $self->items;
    }

    my $value = shift;
    if (!defined($value)) {
        # they passed in only one argument. assume they are checking identity
        ($matcher, $value) = ('identity', $matcher);
    }

    return first {  $_->$matcher eq $value } $self->items;
}

=head2 update Char, Item

This will update TAEB's inventory with the given item in the given slot.

=cut

sub update {
    my $self = shift;
    my $slot = shift;
    my $item = shift;

    TAEB->debug("Inventory: slot '$slot' has item $item.");

    $item->slot($slot);
    $self->set($slot => $item);
}

=head2 decrease_quantity (Str|Item)[, Int]

This will decrease the quantity of items in the given slot. Such as when you
quaff a potion, or throw a dagger. The optional argument is how many of these
items you just lost. Returns the quantity remaining of that item.

=cut

sub decrease_quantity {
    my $self     = shift;
    my $slot     = shift;
    my $quantity = shift || 1;

    my $item;
    if (ref($slot)) {
        ($item, $slot) = ($slot, $slot->slot);
    }
    else {
        $item = $self->get($slot);
    }

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

sub debug_display {
    my $self = shift;
    my @items;

    return "No inventory." unless $self->has_items;

    for my $slot (sort $self->slots) {
        push @items, sprintf '%s - %s', $slot, $self->get($slot);
    }

    return join "\n", @items;
}

make_immutable;

1;


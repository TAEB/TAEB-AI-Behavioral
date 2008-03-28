#!/usr/bin/env perl
package TAEB::World::Inventory;
use TAEB::OO;
use List::Util 'first', 'sum';
use List::MoreUtils 'apply';

use overload %TAEB::Meta::Overload::default;

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

has [qw/wielded offhand quiver left_ring right_ring amulet helmet gloves boots
        body_armor cloak shield/] => (
    isa => 'TAEB::World::Item',
);

has weight => (
    isa      => 'Int',
    required => 1,
    default  => 0,
);

# XXX: redo this like we did with iterate_tiles, sometime when it isn't 5am
sub each {
    my $self = shift;
    my $code = shift;
    my $matcher = shift;

    # pass in a coderef? return the first for which the coderef is true
    if (ref($matcher) eq 'CODE') {
        return apply { $code->($_) } (grep { $matcher->($_) } $self->items);
    }

    # pass in a regex? return the first item for which the regex matches ID
    if (ref($matcher) eq 'Regexp') {
        return apply { $code->($_) } (grep { $_->identity =~ $matcher } $self->items);
    }

    my $value = shift;
    if (!defined($value)) {
        # they passed in only one argument. assume they are checking identity
        ($matcher, $value) = ('identity', $matcher);
    }

    return apply { $code->($_) } (grep { $_->$matcher eq $value } $self->items);
}

sub find {
    my $self = shift;
    my $matcher = shift;

    # pass in a coderef? return the first for which the coderef is true
    if (ref($matcher) eq 'CODE') {
        return first { $matcher->($_) } $self->items;
    }

    # pass in a regex? return the first item for which the regex matches ID
    if (ref($matcher) eq 'Regexp') {
        return first { $_->identity =~ $matcher } $self->items;
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
    my $menu = shift;

    TAEB->debug("Inventory: slot '$slot' has item $item.");

    my $slot_item = $self->get($slot);
    if (defined $slot_item) {
        if ($item->appearance ne $slot_item->appearance) {
            TAEB->error("Adding an item to a used inventory slot");
            $item->slot($slot);
            $self->set($slot => $item);
        }
        elsif (!$menu) {
            TAEB->debug("Increasing the quantity of $slot_item by ".$item->quantity);
            $slot_item->quantity($item->quantity + $slot_item->quantity);
        }
    }
    else {
        $item->slot($slot);
        $self->set($slot => $item);
    }
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

    if (!$item) {
        TAEB->error("Tried to decrease the quantity of empty slot $slot by $quantity.");
        return;
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

sub debug_line {
    my $self = shift;
    my @items;

    return "No inventory." unless $self->has_items;

    for my $slot (sort $self->slots) {
        push @items, sprintf '%s - %s', $slot, $self->get($slot);
    }

    return join "\n", @items;
}

sub msg_got_item {
    my $self = shift;
    my $item = shift;

    return if $item->appearance eq 'gold piece';
    $self->update($item->slot => $item);
}

sub msg_lost_item {
    my $self = shift;
    my $item = shift;

    my $inv_item = $self->find(appearance => $item->appearance);
    $self->decrease_quantity($inv_item->slot, $item->quantity);
}

after set => sub {
    my $self = shift;
    my ($slot, $item) = @_;

    $self->wielded($item)    if $item->is_wielding;
    $self->offhand($item)    if $item->is_offhand;
    $self->quiver($item)     if $item->is_quivered;
    # XXX: make TAEB::World::Item know the difference between left hand and
    #      right hand rings (it's displayed in the inventory)
    #$self->left_ring($item)  if $item->is_left_ring;
    #$self->right_ring($item) if $item->is_right_ring;
    $self->amulet($item)     if $item->class eq 'amulet' && $item->is_wearing;
    # XXX: bah, need to subclass armor
    #$self->helmet($item)     if $item->subclass eq 'helmet' && $item->is_wearing;
    #$self->gloves($item)     if $item->subclass eq 'gloves' && $item->is_wearing;
    #$self->boots($item)      if $item->subclass eq 'boots' && $item->is_wearing;
    #$self->body_armor($item) if $item->subclass eq 'armor' && $item->is_wearing;
    #$self->cloak($item)      if $item->subclass eq 'cloak' && $item->is_wearing;
    #$self->shield($item)     if $item->subclass eq 'shield' && $item->is_wearing;

    $self->weight(sum map { $_->weight } $self->items);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


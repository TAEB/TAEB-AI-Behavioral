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

sub _recalculate_weight {
    my $self = shift;
    $self->weight(sum map { $_->weight * $_->quantity } $self->items);
}

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
        return apply { $code->($_) } (grep { $_->match(identity => $matcher) } $self->items);
    }

    my $value = shift;
    if (!defined($value)) {
        # they passed in only one argument. assume they are checking identity
        ($matcher, $value) = ('identity', $matcher);
    }

    return apply { $code->($_) } (grep { $_->match($matcher => $value) } $self->items);
}

sub find {
    my $self = shift;
    my $matcher = shift;
    my @matches;

    # pass in a coderef? return the first for which the coderef is true
    if (ref($matcher) eq 'CODE') {
        @matches = grep { $matcher->($_) } $self->items;
    }
    # pass in a regex? return the first item for which the regex matches ID
    elsif (ref($matcher) eq 'Regexp') {
        @matches = grep { $_->match(identity => $matcher) } $self->items;
    }
    else {
        unshift @_, $matcher;
        if (@_ == 1) {
            # they passed in only one argument. assume they are checking identity
            unshift @_, 'identity';
        }
        @matches = grep { $_->match(@_) } $self->items;
    }

    return wantarray ? @matches : $matches[0];
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
        if ($item->match(not_appearance => $slot_item->appearance)) {
            TAEB->error("Adding an item to a used inventory slot");
            $item->slot($slot);
            $self->set($slot => $item);
        }
        elsif (!$menu) {
            TAEB->debug("Increasing the quantity of $slot_item by ".$item->quantity);
            $slot_item->quantity($item->quantity + $slot_item->quantity);
        }
        #always update item to be sure we have proper item flags
        else {
            $item->slot($slot);
            $self->set($slot => $item);
        }

    }
    else {
        $item->slot($slot);
        $self->set($slot => $item);
    }
    $self->_recalculate_weight;
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
        $self->_recalculate_weight;
        return 0;
    }

    $item->quantity($new_quantity);
    $self->_recalculate_weight;

    return $new_quantity;
}

sub debug_line {
    my $self = shift;
    my @items;

    return "No inventory." unless $self->has_items;

    for my $slot (sort $self->slots) {
        push @items, sprintf '%s - %s', $slot, $self->get($slot)->debug_line;
    }

    return join "\n", @items;
}

sub msg_got_item {
    my $self = shift;
    my $item = shift;

    return if $item->match(appearance => 'gold piece');
    $self->update($item->slot => $item);
}

sub msg_lost_item {
    my $self = shift;
    my $item = shift;

    my $inv_item = $self->find(appearance => $item->appearance);
    if (defined $inv_item) {
        $self->decrease_quantity($inv_item->slot, $item->quantity);
    }
    else {
        TAEB->error("Which item did we lose? I can't find any item with appearance '".$item->appearance."' in my inventory...");
    }
}

after set => sub {
    my $self = shift;
    my ($slot, $item) = @_;

    $self->wielded($item)    if $item->match(is_wielding => 1);
    $self->offhand($item)    if $item->match(is_offhand => 1);
    $self->quiver($item)     if $item->match(is_quivered => 1);
    # XXX: make TAEB::World::Item know the difference between left hand and
    #      right hand rings (it's displayed in the inventory)
    #$self->left_ring($item)  if $item->match(is_left_ring => 1);
    #$self->right_ring($item) if $item->match(is_right_ring => 1);
    $self->amulet($item)     if $item->match(class => 'amulet',
                                             is_wearing => 1);
    # XXX: bah, need to subclass armor
    #$self->helmet($item)     if $item->match(subclass => 'helmet',
    #                                         is_wearing => 1);
    #$self->gloves($item)     if $item->match(subclass => 'gloves',
    #                                         is_wearing => 1);
    #$self->boots($item)      if $item->match(subclass => 'boots',
    #                                         is_wearing => 1);
    #$self->body_armor($item) if $item->match(subclass => 'body_armor',
    #                                         is_wearing => 1);
    #$self->cloak($item)      if $item->match(subclass => 'cloak',
    #                                         is_wearing => 1);
    #$self->shield($item)     if $item->match(subclass => 'shield',
    #                                         is_wearing => 1);

    $self->_recalculate_weight;
};

around wielded => sub {
    my $orig = shift;
    my $self = shift;

    return $self->$orig unless @_;

    my $wielded = $self->wielded;
    $wielded->is_wielding(0) if $wielded;
    my $ret = $self->$orig(@_);
    $wielded = $self->wielded;
    $wielded->is_wielding(1) if $wielded;

    return $ret;
};

=head2 has_projectile

Returns true (actually, the item) if TAEB has something useful to throw.

=cut

my @projectiles = (
    qr/\bdagger\b/,
    qr/\bspear\b/,
    qr/\bshuriken\b/,
    qr/\bdart\b/,
    qr/\brock\b/,
);

sub has_projectile {
    my $self = shift;

    for my $item (@projectiles) {
        my $projectile = $self->find(sub{ shift->match(
            identity    => $item,
            is_wielding => 0,
            price       => 0,
        )}) or next;
        return $projectile;
    }

    return;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


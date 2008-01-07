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

1;


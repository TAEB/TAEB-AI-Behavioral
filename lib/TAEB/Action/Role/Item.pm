#!/usr/bin/env perl
package TAEB::Action::Role::Item;
use Moose::Role;

has item => (
    is       => 'rw',
    isa      => 'TAEB::Type::ItemOrStr',
    provided => 1,
);

sub exception_missing_item {
    my $self = shift;
    return unless blessed $self->item;

    TAEB->debug("We don't have item " . $self->item . ", escaping.");
    TAEB->inventory->remove($self->item->slot);
    TAEB->enqueue_message(check => 'inventory');
    $self->aborted(1);
    return "\e\e\e";
}

no Moose::Role;

1;


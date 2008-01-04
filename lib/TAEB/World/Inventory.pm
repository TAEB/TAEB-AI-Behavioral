#!/usr/bin/env perl
package TAEB::World::Inventory;
use Moose;
use Moose::Util::TypeConstraints;

has items => (
    is      => 'rw',
    isa     => 'HashRef[TAEB::World::Item]',
    default => sub { {} },
);

sub slot {
    my $self = shift;
    my $slot = shift;

    if (@_) {
        # XXX: ugh
        $self->items(%{ $self->items }, $slot => shift);
    }
    return $self->items->{$slot};
}

1;


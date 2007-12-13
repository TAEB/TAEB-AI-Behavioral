#!/usr/bin/env perl
package TAEB::World::Inventory;
use Moose;
use Moose::Util::TypeConstraints;

subtype 'AlphaKeys'
     => as 'HashRef'
     => where { 0 == grep /[^a-zA-Z]/ keys %$_ };

has items => (
    is      => 'rw',
    isa     => 'AlphaKeys[TAEB::World::Item]',
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


#!/usr/bin/env perl
package TAEB::World::Item::Role::Wearable;
use Moose::Role;

has is_wearing => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

around 'can_drop' => sub {
    my $orig = shift;
    my $self = shift;

    return 0 if $self->is_wearing;
    return $self->$orig(@_);
};

no Moose::Role;

1;


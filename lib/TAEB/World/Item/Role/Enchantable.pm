#!/usr/bin/env perl
package TAEB::World::Item::Role::Enchantable;
use Moose::Role;

has enchantment => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

sub ench {
    my $self = shift;
    my $ench = $self->enchantment;
    return $ench if $ench < 0;
    return "+$ench";
}

1;


#!/usr/bin/env perl
package TAEB::World::Item::Role::Chargeable;
use Moose::Role;

has recharges => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has charges => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => undef,
);

sub spend_charge {
    my $self = shift;
    return if !defined($self->charges);
    TAEB->error("Tried to spend a charge with no charges to spare!")
        if $self->charges == 0;
    $self->charges($self->charges - 1);
}

sub chance_to_recharge {
    my $self = shift;
    my $n = $self->recharges;

    # can always recharge at 0 recharges
    return 100 if $n == 0;

    # can recharge /oW only once
    return 0 if $self->identity eq 'wand of wishing';

    # (n/7)^3
    # XXX: probably OK to use floating point
    return 100 - int(100 * (($n/7) ** 3));
}

1;


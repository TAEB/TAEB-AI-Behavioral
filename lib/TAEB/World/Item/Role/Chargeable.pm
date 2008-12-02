#!/usr/bin/env perl
package TAEB::World::Item::Role::Chargeable;
use Moose::Role;

has recharges => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has charges => (
    is        => 'rw',
    isa       => 'Int',
    predicate => 'known_charges',
    clearer   => 'set_charges_unknown',
);

sub spend_charge {
    my $self = shift;
    my $count = shift || 1;

    return unless $self->known_charges;
    $self->charges($self->charges - $count);
    if ($self->charges < 0) {
        $self->charges(0);
        TAEB->log->item("$self had less than 0 charges!");
    }
}

sub recharge {
    my $self = shift;

    $self->set_charges_unknown;
    $self->recharges($self->recharges + 1);
}

sub chance_to_recharge {
    my $self = shift;
    my $n = $self->recharges;

    # can always recharge at 0 recharges
    return 100 if $n == 0;

    # can recharge /oW only once
    return 0 if $self->match(identity => 'wand of wishing');

    # (n/7)^3
    # XXX: probably OK to use floating point
    return 100 - int(100 * (($n/7) ** 3));
}

no Moose::Role;

1;


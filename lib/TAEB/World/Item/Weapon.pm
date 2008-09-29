#!/usr/bin/env perl
package TAEB::World::Item::Weapon;
use TAEB::OO;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Enchantable';
with 'TAEB::World::Item::Role::Erodable';

has '+class' => (
    default => 'weapon',
);

has is_poisoned => (
    isa     => 'Bool',
    default => 0,
);

around 'can_drop' => sub {
    my $orig = shift;
    my $self = shift;

    #XXX: We currently don't want TAEB to drop any weapon he may be using
    #in the future change his to only if that weapon is cursed
    return 0 if $self->is_wielding;
    return $self->$orig(@_);
};

__PACKAGE__->install_spoilers(qw/sdam ldam tohit hands/);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


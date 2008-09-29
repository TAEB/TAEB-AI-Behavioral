#!/usr/bin/env perl
package TAEB::World::Item::Spellbook;
use TAEB::OO;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Writable';

has '+class' => (
    default => 'spellbook',
);

has difficult => (
    isa     => 'Int',
    default => 0,
);

sub spell {
    my $self = shift;
    
    return unless defined $self->identity;
    $self->identity =~ m/spellbook of (.*)/;
    return $1;
}

__PACKAGE__->install_spoilers(qw/level read marker emergency role/);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


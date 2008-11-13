#!/usr/bin/env perl
package TAEB::Action::Melee;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

has '+direction' => (
    required => 1,
);

# sadly, Melee doesn't give an "In what direction?" message
sub command {
    'F' . shift->direction
}

sub msg_killed {
    my ($self, $critter) = @_;

    $self->target_tile->witness_kill($critter);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;



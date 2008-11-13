#!/usr/bin/env perl
package TAEB::Action::Melee;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

has '+direction' => (
    required => 1,
);

has monster => (
    isa       => 'TAEB::World::Monster',
    predicate => 'has_monster',
);

sub BUILD {
    my $self = shift;

    if (my $monster = $self->target_tile->monster) {
        $self->monster($monster);
    }
}

# sadly, Melee doesn't give an "In what direction?" message
sub command {
    'F' . shift->direction
}

sub msg_killed {
    my ($self, $monster_name) = @_;

    $self->target_tile->witness_kill($monster_name);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;



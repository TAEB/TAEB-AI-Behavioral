#!/usr/bin/env perl
package TAEB::AI::Behavior::BuffSelf;
use Moose;
extends 'TAEB::AI::Behavior';

has protection_level => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

sub prepare {
    my $self = shift;

    if (my $spell = TAEB->find_castable("protection")) {
        $self->next("Z" . $spell->slot);
        $self->currently("Casting protection.");
        return $self->protection_level ? 50 : 100;
    }

    return 0;
}

sub urgencies {
    return {
       100 => "casting the first hit of protection",
        50 => "casting a subsequent hit of protection",
    },
}

sub msg_protection {
    my $self         = shift;
    my $is_protected = shift;
    my $delta        = shift;

    $self->protection_level($self->protection_level + $delta);
    if ($self->protection_level xor $is_protected) {
        $self->protection_level($is_protected);
    }
}

make_immutable;

1;


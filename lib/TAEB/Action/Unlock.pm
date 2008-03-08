#!/usr/bin/env perl
package TAEB::Action::Unlock;
use Moose;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

use constant command => 'a';

has implement => (
    is       => 'rw',
    isa      => 'TAEB::World::Item',
    required => 1,
);

sub respond_apply_what { shift->implement->slot }

sub respond_lock {
    $tile->locked('unlocked');
    return 'n';
}

sub respond_unlock {
    $tile->locked('locked');
    return 'y';
}

sub msg_unlocked_door {
    my $tile = $self->target_tile('closeddoor');
    $tile->locked('unlocked');
}

sub msg_door {
    my $self = shift;
    my $type = shift;

    my $tile = $self->target_tile('closeddoor');

    if ($type eq 'just_unlocked') {
        $tile->locked('unlocked');
    }
}

make_immutable;

1;


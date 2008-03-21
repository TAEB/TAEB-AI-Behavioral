#!/usr/bin/env perl
package TAEB::Action::Unlock;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

use constant command => 'a';

has implement => (
    isa      => 'TAEB::World::Item',
    required => 1,
);

sub respond_apply_what { shift->implement->slot }

sub respond_lock { 'n' }
sub respond_unlock { 'y' }

sub msg_just_unlocked_door {
    shift->target_tile('closeddoor')->locked('unlocked');
}

sub msg_interrupted_unlocking {
    shift->target_tile('closeddoor')->locked('locked');
}

sub msg_door {
    my $self = shift;
    my $type = shift;

    my $tile = $self->target_tile('closeddoor');

    if ($type eq 'just_unlocked') {
        $tile->locked('unlocked');
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


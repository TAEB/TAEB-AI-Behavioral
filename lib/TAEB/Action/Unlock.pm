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
    # XXX: mark the door as unlocked
    return 'n';
}

sub respond_unlock {
    # XXX: mark the door as locked (we'll unlock it soon)
    return 'y';
}

sub msg_unlocked_door {
    # XXX: mark the door as unlocked
}

make_immutable;

1;


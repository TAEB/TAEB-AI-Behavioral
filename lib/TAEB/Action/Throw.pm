#!/usr/bin/env perl
package TAEB::Action::Throw;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

use TAEB::Util 'vi2delta';

use constant command => 't';

has item => (
    isa      => 'TAEB::World::Item',
    required => 1,
);

sub respond_throw_what { shift->item->slot }

# we don't get a message when we throw one dagger
sub done {
    my $self = shift;
    TAEB->inventory->decrease_quantity($self->item->slot);

    # now mark squares in the path of the projectile as interesting so we pick
    # up projectiles we've thrown
    my ($dx, $dy) = vi2delta($self->direction);
    for (1 .. 8) {
        my $tile = TAEB->current_level->at($dx * $_, $dy * $_)
            or next;
        $tile->interesting_at(TAEB->turn);
    }
}

sub msg_throw_count {
    my $self  = shift;
    my $count = shift;

    # done takes care of the other one
    TAEB->inventory->decrease_quantity($self->item->slot, $count - 1);
}

sub exception_missing_item {
    my $self = shift;
    TAEB->debug("We don't have item " . $self->item . ", escaping.");
    TAEB->inventory->remove($self->item->slot);
    $self->aborted(1);
    return "\e";
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


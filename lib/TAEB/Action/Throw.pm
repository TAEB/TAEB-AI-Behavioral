#!/usr/bin/env perl
package TAEB::Action::Throw;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';
with 'TAEB::Action::Role::Item';

use TAEB::Util 'vi2delta';

use constant command => 't';

has '+item' => (
    isa      => 'TAEB::Type::Item',
    required => 1,
);

has '+direction' => (
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
    my ($x, $y)   = (TAEB->x, TAEB->y);

    for (1 .. $self->item->throw_range) {
        $x += $dx;
        $y += $dy;

        my $tile = TAEB->current_level->at($x, $y)
            or next;
        $tile->interesting_at(TAEB->turn) unless $tile->glyph eq '.';
    }
}

sub msg_throw_count {
    my $self  = shift;
    my $count = shift;

    # done takes care of the other one
    TAEB->inventory->decrease_quantity($self->item->slot, $count - 1);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


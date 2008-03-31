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

has target_tile => (
    isa => 'TAEB::World::Tile',
);

has threw_multiple => (
    isa     => 'Bool',
    default => 0,
);

has killed => (
    isa     => 'Bool',
    default => 0,
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
            or last;
        $tile->is_walkable(1)
            or last;

        # if we're throwing at a monster, then the projectile will always stop
        # at the monster's tile (unless we threw multiple and it killed the
        # monster - the subsequent projectiles can fly past)
        if ($tile == $self->target_tile) {
            last unless $self->threw_multiple
                     && $self->killed;
        }

        # . tiles would show the projectile we threw
        next if $tile->glyph eq '.';

        $tile->interesting_at(TAEB->turn);
    }
}

sub msg_throw_count {
    my $self  = shift;
    my $count = shift;

    $self->threw_multiple($count);

    # done takes care of the other one
    TAEB->inventory->decrease_quantity($self->item->slot, $count - 1);
}

sub msg_killed {
    my $self = shift;

    $self->killed(1);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


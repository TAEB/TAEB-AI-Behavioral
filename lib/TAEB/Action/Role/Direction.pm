#!/usr/bin/env perl
package TAEB::Action::Role::Direction;
use Moose::Role;
use List::MoreUtils 'none';

has direction => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub respond_what_direction { shift->direction }

sub target_tile {
    my $self = shift;
    my $tile = TAEB->current_level->at_direction($self->direction);

    if (@_ && none { $tile->type eq $_ } @_) {
        TAEB->warning(blessed($self) . " can only handle tiles of type: @_");
    }

    return $tile;
}

1;


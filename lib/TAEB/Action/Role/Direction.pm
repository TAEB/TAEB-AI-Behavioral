#!/usr/bin/env perl
package TAEB::Action::Role::Direction;
use Moose::Role;

has direction => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub respond_what_direction { shift->direction }

sub target_tile {
    my $self = shift;
    my $tile = TAEB->current_level->at_delta($self->direction);

    if (@_ && grep { $tile->type eq $_ } @_ == 0) {
        TAEB->warning(blessed($self) . " can only handle tiles of type: @_");
    }

    return $tile;
}

1;


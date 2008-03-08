#!/usr/bin/env perl
package TAEB::Action::Search;
use Moose;
extends 'TAEB::Action';

has started => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { TAEB->turn },
);

has iterations => (
    is      => 'rw',
    isa     => 'Int',
    default => 10,
);

sub command { shift->iterations . 's' }

sub done {
    my $self = shift;
    my $diff = TAEB->turn - $self->started;

    TAEB->each_adjacent(sub {
        my $self = shift;
        $self->searched($self->searched + $diff);
    });
}

make_immutable;

1;


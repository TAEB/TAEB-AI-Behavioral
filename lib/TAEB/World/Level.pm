#!/usr/bin/env perl
package TAEB::World::Level;
use Moose;

has tiles => (
    is      => 'rw',
    isa     => 'ArrayRef[ArrayRef[TAEB::World::Tile]]',
    default => sub {
        my $self = shift;
        # ugly, but ok
        [ map {
            [ map {
                TAEB::World::Tile->new(level => $self)
            } 0 .. 79 ]
        } 0 .. 23 ]
    },
);

has branch => (
    is       => 'rw',
    isa      => 'TAEB::World::Branch',
    weak_ref => 1,
);

has z => (
    is  => 'rw',
    isa => 'Int',
);

1;


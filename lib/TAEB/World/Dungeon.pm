#!/usr/bin/env perl
package TAEB::World::Dungeon;
use Moose;

has branches => (
    is      => 'rw',
    isa     => 'HashRef[TAEB::World::Branch]',
    default => sub {
        my $self = shift;

        my @names = qw/dungeons gehennom mines quest
                       sokoban ludios vlad planes/;
        { map { $_ => TAEB::World::Branch->new(name => $_, dungeon => $self) }
              @names }
    },
);

has current_level => (
    is => 'rw',
    isa => 'TAEB::World::Level',
);

1;


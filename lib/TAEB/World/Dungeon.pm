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
    handles => [qw/z/],
);

has cartographer => (
    is      => 'rw',
    isa     => 'TAEB::World::Cartographer',
    default => sub {
        my $self = shift;
        TAEB::World::Cartographer->new(dungeon => $self)
    },
    handles => [qw/update x y/],
);

# we start off in dungeon 1. this helps keeps things tidy (we only have to
# worry about level generation on level change)
sub BUILD {
    my $self = shift;
    my $dungeons = $self->branches->{dungeons};
    my $level = TAEB::World::Level->new(branch => $dungeons, z => 1);
    $dungeons->levels([$level]);
    $self->current_level($level);
}

1;


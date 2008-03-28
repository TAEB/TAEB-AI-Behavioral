#!/usr/bin/env perl
package TAEB::World::Dungeon;
use TAEB::OO;

has branches => (
    isa     => 'HashRef[TAEB::World::Branch]',
    default => sub {
        my $self = shift;

        my @names = qw/dungeons gehennom mines quest
                       sokoban ludios vlad planes/;
        return {
            map { $_ => TAEB::World::Branch->new(name => $_, dungeon => $self) }
                @names
          }
    },
);

has current_level => (
    isa => 'TAEB::World::Level',
    handles => [qw/z/],
);

has cartographer => (
    isa     => 'TAEB::World::Cartographer',
    default => sub {
        my $self = shift;
        TAEB::World::Cartographer->new(dungeon => $self)
    },
    handles => [qw/update x y map_like/],
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

=head2 current_tile -> Tile

The tile TAEB is currently standing on.

=cut

sub current_tile {
    my $self = shift;
    $self->current_level->at;
}

for my $tiletype (qw/orthogonal diagonal adjacent adjacent_inclusive/) {
    for my $controllertype (qw/each any all/) {
        my $method = "${controllertype}_${tiletype}";
        __PACKAGE__->meta->add_method($method => sub {
            my $self = shift;
            my $code = shift;
            my $tile = shift || $self->current_tile;

            $tile->$method($code);
        })
    }
}

=head2 nearest_level Code -> Maybe Level

Finds the nearest level for which the code reference returns true.

=cut

sub nearest_level {
    my $self = shift;
    my $code = shift;

    my @queue = TAEB->current_level;
    while (my $level = shift @queue) {
        return $level if $code->($level);
        push @queue, $_ for $level->exits;
    }

    return;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::World::Dungeon;
use TAEB::OO;
use Scalar::Util 'refaddr';

has levels => (
    isa     => 'ArrayRef[ArrayRef[TAEB::World::Level]]',
    default => sub { [] },
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
    my @dlvl1 = $self->get_levels(1);
    $self->current_level($dlvl1[0]);
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
    my %seen;

    while (my $level = shift @queue) {
        ++$seen{refaddr $level};
        return $level if $code->($level);

        push @queue, grep { !$seen{refaddr $_} } $level->adjacent_levels;
    }

    return;
}

sub get_levels {
    my $self = shift;
    my $dlvl = shift;

    my $index = $dlvl - 1;

    unless ($self->levels->[$index]) {
        TAEB->info("Creating a new level object in check_dlvl for $self, dlvl=$dlvl, index $index");

        $self->levels->[$index] = [
            TAEB::World::Level->new(
                z       => $dlvl,
                dungeon => $self,
            )
        ]
    }

    if (!wantarray) {
        TAEB->error("Called get_levels in scalar context. Fix your code.");
        return undef;
    }

    return @{ $self->levels->[$index] };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


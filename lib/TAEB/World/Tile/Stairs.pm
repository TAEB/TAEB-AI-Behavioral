#!/usr/bin/env perl
package TAEB::World::Tile::Stairs;
use Moose;
extends 'TAEB::World::Tile';

has other_side => (
    is       => 'rw',
    isa      => 'TAEB::World::Tile::Stairs',
    weak_ref => 1,
);

has '+type' => (
    default => 'stairs',
);

sub new_from {
    my $self = shift;
    my %args = @_;

    my $tile = delete $args{tile}
        or confess "Must pass tile to TAEB::World::Tile::Stairs->new_from";

    for (qw/x y level stepped_on/) {
        $args{$_} = $tile->$_;
    }

    $self->new(%args, type => 'stairs');
}

1;


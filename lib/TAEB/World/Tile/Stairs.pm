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
    my $tile = shift;

    my %args;

    while (my ($name, $attr) = each %{ $tile->meta->get_attribute_map }) {
        my $reader = $attr->get_read_method;
        my $value = $tile->$reader;
        $args{$name} = $value if defined $value;
    }

    $self->new(%args, type => 'stairs');
}

1;


#!/usr/bin/env perl
package TAEB::World::Monster;
use TAEB::OO;
use String::Koremutake;

has id => (
    is      => 'ro',
    isa     => 'Str',
    default => sub {
        my $k = String::Koremutake->new;
        return $k->integer_to_koremutake(int(rand(2**31)));
    },
);

has tile => (
    isa      => 'TAEB::World::Tile',
    weak_ref => 1,
);

has type => (
    isa => 'Str',
);

has peaceful => (
    isa     => 'Bool',
    default => 0,
);

has tame => (
    isa     => 'Bool',
    default => 0,
);

make_immutable;
no Moose;

1;


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
    is       => 'rw',
    isa      => 'TAEB::World::Tile',
    weak_ref => 1,
);

has name => (
    is  => 'rw',
    isa => 'Str',
);

has ac => (
    is  => 'rw',
    isa => 'Int',
);

has mr => (
    is  => 'rw',
    isa => 'Int',
);

has level => (
    is  => 'rw',
    isa => 'Int',
);

has speed => (
    is  => 'rw',
    isa => 'Int',
);

has attacks => (
    is  => 'rw',
    isa => 'Str',
);

has resistances => (
    is  => 'rw',
    isa => 'Str',
);

has elbereth => (
    is            => 'rw',
    isa           => 'Bool',
    default       => 1,
    documentation => "whether the monster respects Elbereth",
);

has glyph => (
    is  => 'rw',
    isa => 'Str',
);

has color => (
    is  => 'rw',
    isa => 'Str',
);

has peaceful => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has tame => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has shopkeeper => (
    is  => 'rw',
    isa => 'Bool',
);

make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::World::Monster;
use TAEB::OO;

has glyph => (
    isa      => 'Str',
    required => 1,
);

has color => (
    isa      => 'Str',
    required => 1,
);

has tile => (
    isa      => 'TAEB::World::Tile',
    weak_ref => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


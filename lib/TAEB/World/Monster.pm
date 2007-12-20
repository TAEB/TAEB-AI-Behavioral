#!/usr/bin/env perl
package TAEB::World::Monster;
use Moose;

has 'id' => (
  is  => 'rw',
  isa => 'Str',
);

has 'name' => (
  is  => 'rw',
  isa => 'Str',
);

has 'ac' => (
  is  => 'rw',
  isa => 'Int',
);

has 'mr' => (
  is  => 'rw',
  isa => 'Int',
);

has 'lev' => (
  is  => 'rw',
  isa => 'Int',
);

has 'spd' => (
  is  => 'rw',
  isa => 'Int',
);

# whether the monster respects Elbereth
has 'elbereth' => (
  is      => 'rw',
  isa     => 'Int',
  default => 1,
);

has 'glyph' => (
  is  => 'rw',
  isa => 'Str',
);

has 'color' => (
  is  => 'rw',
  isa => 'Str',
);

1;


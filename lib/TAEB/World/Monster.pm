#!/usr/bin/env perl
package TAEB::World::Monster;
use TAEB::OO;
use TAEB::Util qw/:colors/;

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

sub is_shk {
    my $self = shift;
    $self->glyph eq '@' && $self->color eq COLOR_WHITE;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


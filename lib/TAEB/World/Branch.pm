#!/usr/bin/env perl
package TAEB::World::Branch;
use TAEB::OO;

use overload
    q{""} => sub {
        my $self = shift;
        sprintf "[%s: name=%s]",
            $self->meta->name,
            $self->name;
    };

has name => (
    isa      => 'Str',
    required => 1,
);

has levels => (
    isa => 'ArrayRef[TAEB::World::Level]',
);

has dungeon => (
    isa      => 'TAEB::World::Dungeon',
    weak_ref => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;


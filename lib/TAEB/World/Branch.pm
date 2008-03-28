#!/usr/bin/env perl
package TAEB::World::Branch;
use TAEB::OO;

use overload
    %TAEB::Meta::Overload::default,
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

sub get_level {
    my $self = shift;
    my $dlvl = shift;

    my $index = $dlvl - 1;

    unless ($self->levels->[$index]) {
        TAEB->info("Creating a new level object in check_dlvl for $self, dlvl=$dlvl, index $index");

        $self->levels->[$index] = TAEB::World::Level->new(
            branch => $self,
            z      => $dlvl,
        );
    }

    return $self->levels->[$index];
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


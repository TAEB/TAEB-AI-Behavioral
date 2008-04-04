#!/usr/bin/perl
package TAEB::Action::Name;
use TAEB::OO;
use String::Koremutake;
extends 'TAEB::Action';

use constant command => "#name\n";

has item => (
    isa      => 'TAEB::World::Item',
    required => 1,
    provided => 1,
);

has name => (
    isa      => 'Str',
    required => 1,
    lazy     => 1,
    provided => 1,
    default  => sub {
        my $self = shift;
        my $k = String::Koremutake->new;
        $self->item->appearance . $k->integer_to_koremutake(int(rand(2**31)));
    },
);

has specific => (
    isa      => 'Bool',
    required => 1,
    default  => 0,
    provided => 1,
);

sub respond_name_specific {
    return 'y' if shift->specific;
    return 'n';
}

sub respond_name_what {
    return shift->item->slot;
}

sub respond_name {
    return shift->name . "\n";
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


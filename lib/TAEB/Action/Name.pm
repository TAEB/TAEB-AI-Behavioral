#!/usr/bin/perl
package TAEB::Action::Name;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "#name\n";

has item => (
    traits   => [qw/TAEB::Provided/],
    isa      => 'TAEB::World::Item',
    required => 1,
);

has name => (
    traits   => [qw/TAEB::Provided/],
    isa      => 'Str',
    required => 1,
);

has specific => (
    traits   => [qw/TAEB::Provided/],
    isa      => 'Bool',
    required => 1,
    default  => 0,
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


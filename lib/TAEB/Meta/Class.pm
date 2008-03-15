#!/usr/bin/env perl
package TAEB::Meta::Class;
use Moose;
extends 'Moose::Meta::Class';

use TAEB::Meta::Attribute;

around initialize => sub {
    my $orig = shift;
    my $self = shift;
    my $pkg  = shift;

    $self->$orig($pkg,
        attribute_metaclass => 'TAEB::Meta::Attribute',
        method_metaclass    => 'Moose::Meta::Method',
        instance_metaclass  => 'Moose::Meta::Instance',
        @_,
    );
};

no Moose;

1;


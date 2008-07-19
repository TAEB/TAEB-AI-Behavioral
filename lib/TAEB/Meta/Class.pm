#!/usr/bin/env perl
package TAEB::Meta::Class;
use Moose;
extends 'Moose::Meta::Class';

use TAEB::Meta::Attribute;
use TAEB::Meta::Role::AppInit;
use TAEB::Meta::Role::Subscription;

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

before make_immutable => sub {
    my $self = shift;
    $self->add_role(TAEB::Meta::Role::AppInit->meta);
    $self->add_role(TAEB::Meta::Role::Subscription->meta)
        if (any { /^(?:msg|exception|respond)_/ } $self->get_method_list);
};

no Moose;

1;


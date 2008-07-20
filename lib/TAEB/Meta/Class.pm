#!/usr/bin/env perl
package TAEB::Meta::Class;
use Moose;
use List::MoreUtils qw/any/;
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

before make_immutable => sub {
    my $self = shift;
    Moose::Util::apply_all_roles($self, 'TAEB::Meta::Role::Initialize');
    Moose::Util::apply_all_roles($self, 'TAEB::Meta::Role::Subscription')
        if (any { /^(?:msg|exception|respond)_/ } $self->get_method_list);
};

no Moose;

1;


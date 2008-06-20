#!/usr/bin/env perl
package TAEB::Meta::Trait::Provided;
use Moose::Role;

has provided => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

no Moose::Role;

package Moose::Meta::Attribute::Custom::Trait::Provided;
sub register_implementation { 'TAEB::Meta::Trait::Provided' }

1;


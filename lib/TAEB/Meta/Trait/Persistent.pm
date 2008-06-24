#!/usr/bin/env perl
package TAEB::Meta::Trait::Persistent;
use Moose::Role;

before _process_options => sub {
    my ($class, $name, $options) = @_;

    $options->{lazy} = 1;

    $options->{default}
        || confess "Persistent attribute ($name) must have a default value.";
};

package Moose::Meta::Attribute::Custom::Trait::TAEB::Persistent;
sub register_implementation { 'TAEB::Meta::Trait::Persistent' }

1;


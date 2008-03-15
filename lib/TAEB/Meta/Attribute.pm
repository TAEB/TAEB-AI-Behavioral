#!/usr/bin/env perl
package TAEB::Meta::Attribute;
use Moose;
extends 'Moose::Meta::Attribute';

has '+is' => (
    default => 'rw',
);

around _process_options => sub {
    my $orig = shift;
    my ($class, $name, $options) = @_;

    $options->{is} ||= 'rw';

    $orig->(@_);
};

no Moose;

1;


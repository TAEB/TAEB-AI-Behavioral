#!/usr/bin/env perl
package TAEB::OO;
use Moose ();
use MooseX::ClassAttribute ();
use Moose::Exporter;

use TAEB::Meta::Class;
use TAEB::Meta::Trait::Provided;
use TAEB::Meta::Trait::Persistent;
use TAEB::Meta::Types;
use TAEB::Meta::Overload;

Moose::Exporter->setup_import_methods(
    also => ['Moose', 'MooseX::ClassAttribute'],
);

sub init_meta {
    shift;
    return Moose->init_meta(@_, metaclass => 'TAEB::Meta::Class');
}

1;


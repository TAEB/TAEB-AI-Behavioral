#!/usr/bin/env perl
package TAEB::OO;
use Moose ();
use MooseX::ClassAttribute ();
use Moose::Exporter;

use Sub::Name;

use TAEB::Meta::Class;
use TAEB::Meta::Trait::Provided;
use TAEB::Meta::Trait::Persistent;
use TAEB::Meta::Types;
use TAEB::Meta::Overload;

Moose::Exporter->setup_import_methods(
    with_caller => [ 'install_spoilers' ],
    also        => ['Moose', 'MooseX::ClassAttribute'],
);

sub install_spoilers {
    my $caller = shift;

    for my $field (@_) {
        $caller->meta->add_method($field => sub {
            shift->lookup_spoiler($field);
        });
    }
}

sub init_meta {
    shift;
    return Moose->init_meta(@_, metaclass => 'TAEB::Meta::Class');
}

1;


#!/usr/bin/env perl
package TAEB::Knowledge;
use MooseX::Singleton;

use TAEB::Knowledge::Item;
use TAEB::Knowledge::Item::Wand;

has types => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    auto_deref => 1,
    default => sub { [qw/Wand/] },
);

has appearances => (
    is      => 'rw',
    isa     => 'HashRef[HashRef[TAEB::Knowledge::Item]]',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $appearances = {};

        for my $type ($self->types) {
            my $class = "TAEB::Knowledge::Item::$type";
            for my $appearance ($class->all_appearances) {
                $appearances->{lc $type}{$appearance} = $class->new(
                    appearance => $appearance,
                );
            }
        }

        return $appearances;
    },
);

1;


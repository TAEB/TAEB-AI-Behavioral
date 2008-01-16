#!/usr/bin/env perl
package TAEB::Knowledge;
use MooseX::Singleton;

use TAEB::Knowledge::Item;
use TAEB::Knowledge::Item::Wand;
use TAEB::Knowledge::Item::Ring;

has types => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    auto_deref => 1,
    default => sub { [qw/Wand Ring/] },
);

has appearances => (
    is      => 'rw',
    isa     => 'HashRef[HashRef[TAEB::Knowledge::Item]]',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $appearances = {};

        for my $type ($self->types) {
            my $class = "TAEB::Spoilers::Item::$type";
            my $knowledgeclass = "TAEB::Knowledge::Item::$type";
            for my $appearance ($class->all_appearances) {
                $appearances->{lc $type}{$appearance} = $knowledgeclass->new(
                    appearance => $appearance,
                    type       => lc($type),
                );
            }
        }

        return $appearances;
    },
);

1;


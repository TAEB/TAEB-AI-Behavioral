#!/usr/bin/env perl
package TAEB::Spoilers::Item::Artifact;
use MooseX::Singleton;
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $artifacts = { };

        for (qw/Amulet Armor Gem Tool Weapon/) {
            my $list = "TAEB::Spoilers::Item::$_"->list;
            for my $name (keys %$list) {
                my $stats = $list->{$name};
                next unless $stats->{artifact};
                $artifacts->{$name} = $stats;
            }
        }

        return $artifacts;
    },
);

sub artifact {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return unless $item;
    return $self->list->{$item};
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


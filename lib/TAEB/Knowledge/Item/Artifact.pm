#!/usr/bin/env perl
package TAEB::Knowledge::Item::Artifact;
use MooseX::Singleton;
use TAEB::Knowledge::Item::Weapon;

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $artifacts = { };

        for (qw/Weapon/) {
            my $list = "TAEB::Knowledge::Item::$_"->list;
            while (my ($name, $stats) = each %$list) {
                next unless $stats->{artifact};
                $artifacts->{$name} = $stats;
            }
        }

        return $artifacts;
    },
);

sub artifact {
    my $self = shift;
    my $item = TAEB::Knowledge::Item->canonicalize_item(shift);

    return $self->list->{$item};
}

sub seen {
    my $self = shift;
    my $name = shift;
    my $artifact = $self->artifact($name) or do {
        warn "No artifact found for '$name'.";
        return 0;
    };

    if (@_) {
        return $artifact->{seen} = shift;
    }
    return $artifact->{seen};
}

1;


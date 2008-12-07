#!/usr/bin/env perl
package TAEB::Knowledge::Item::Artifact;
use TAEB::OO;
use Set::Object;

has _seen_artifacts => (
    isa     => 'Set::Object',
    default => sub { Set::Object->new },
    handles => {
        seen     => 'insert',
        was_seen => 'contains',
        all_seen => 'elements',
        num_seen => 'size',
    },
);

around qw/seen was_seen/ => sub {
    my $orig = shift;
    my $self = shift;
    my $artifact = shift;

    my $name;
    if (ref($artifact) eq '') {
        $name = $artifact;
    }
    elsif ($artifact->isa('TAEB::World::Item')) {
        $name = $artifact->identity;
    }
    else {
        warn 'Unknown class for artifact: ', ref $artifact;
        return 0;
    }

    $artifact = TAEB::Spoilers::Item::Artifact->artifact($name) or do {
        warn "No artifact found for '$name'.";
        return 0;
    };

    return $self->$orig($artifact);
};

sub msg_excalibur { shift->seen('Excalibur') }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


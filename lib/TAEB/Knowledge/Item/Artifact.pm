#!/usr/bin/env perl
package TAEB::Knowledge::Item::Artifact;
use TAEB::OO;
use MooseX::AttributeHelper::Set::Object;
extends 'TAEB::Knowledge::Item';

has _seen_artifacts => (
    metaclass => 'Set::Object',
    provides => {
        insert => 'seen',
        contains => 'was_seen',
        elements => 'all_seen',
        size   => 'num_seen',
    },
);

sub _normalize_artifact_modifier {
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
}

around seen => \&_normalize_artifact_modifier;
around was_seen => \&_normalize_artifact_modifier;

sub BUILD { TAEB->publisher->subscribe(shift); }

sub msg_excalibur { shift->seen('Excalibur') }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


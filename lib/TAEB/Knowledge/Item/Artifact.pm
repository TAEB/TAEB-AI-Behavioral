#!/usr/bin/env perl
package TAEB::Knowledge::Item::Artifact;
use TAEB::OO;
use MooseX::AttributeHelper::Set::Object;

has _seen_artifacts => (
    metaclass => 'Set::Object',
    provides => {
        insert   => 'seen',
        contains => 'was_seen',
        elements => 'all_seen',
        size     => 'num_seen',
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

before _app_init => sub { TAEB->publisher->subscribe(shift) };

sub msg_excalibur { shift->seen('Excalibur') }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::Knowledge::Spell;
use TAEB::OO;

use overload
    q{""} => sub {
        shift->debug_display;
    };

has name => (
    isa      => 'Str',
    required => 1,
);

has learned_at => (
    isa      => 'Int',
    default  => sub { TAEB->turn },
);

has fail => (
    isa      => 'Int',
    required => 1,
);

has slot => (
    isa      => 'Str',
    required => 1,
);

has spoiler => (
    is      => 'ro',
    isa     => 'Hash::Inflator',
    lazy    => 1,
    handles => [qw/level read marker/],
    default => sub {
        my $self = shift;
        my $name = "spellbook of " . $self->name;

        Hash::Inflator->new(TAEB::Spoilers::Item::Spellbook->list->{$name});
    },
);

=head2 castable

Can this spell be cast this turn? This does not only take into account spell
age, but also whether you're confused, have enough power, etc.

=cut

sub castable {
    my $self = shift;

    return 0 if $self->forgotten;
    return 0 if $self->power > TAEB->power;

    # "You are too hungry to cast!" (detect food is exempted by NH itself)
    return 0 if TAEB->senses->nutrition <= 10 && $self->name ne 'detect food';

    return 1;
}

sub forgotten {
    my $self = shift;
    return TAEB->turn > $self->learned_at + 20_000;
}

sub debug_display {
    my $self = shift;

    return sprintf '[%s: %s - %s (%d)]',
           blessed($self),
           $self->slot,
           $self->name,
           $self->learned_at;
}

sub power { 5 * shift->level }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


#!/usr/bin/env perl
package TAEB::Knowledge::Spell;
use Moose;

has name => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has learned_at => (
    is       => 'rw',
    isa      => 'Int',
    default  => sub { TAEB->turn },
);

=head2 castable

Can this spell be cast this turn? This does not only take into account spell
age, but also whether you're confused, have enough power, etc.

=cut

sub castable {
    my $self = shift;

    return 0 if $self->forgotten;
    return 1;
}

sub forgotten {
    return $self->learned_at + 20_000 >= TAEB->turn;
}

1;


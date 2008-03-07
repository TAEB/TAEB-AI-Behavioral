#!/usr/bin/env perl
package TAEB::World::Spells;
use Moose;
extends 'TAEB::World::Inventory';

my @slots = 'a' .. 'z', 'A' .. 'Z';

has _spells => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef[TAEB::Knowledge::Spell]',
    default   => sub { {} },
    provides  => {
        get    => 'get',
        set    => 'set',
        values => 'spells',
        keys   => 'slots',
        empty  => 'has_spells',
    },
);

sub castable_spells {
    my $self = shift;
    return grep { $_->castable } $self->spells;
}

sub forgotten_spells {
    my $self = shift;
    return grep { $_->forgotten } $self->spells;
}

sub msg_know_spell {
    my $self = shift;
    my ($slot, $name, $forgotten, $fail) = @_;

    my $spell = $self->get($slot);
    if (!defined($spell)) {
        $spell = TAEB::Knowledge::Spell->new(name => $name, fail => $fail);
        $self->set($slot => $spell);
    }
    else {
        if ($spell->fail != $fail) {
            TAEB->debug("Setting " . $spell->name . "'s failure rate to $fail% (was ". $spell->fail ."%).");
            $spell->fail($fail);
        }
    }

    # update whether we have forgotten the spell or not?
    # this is potentially run when we save and reload
    if ($spell->forgotten xor $forgotten) {
        if ($forgotten) {
            TAEB->debug("Setting " . $spell->name . "'s learned at to 20,001 turns ago (".(TAEB->turn - 20_001)."), was ".$spell->learned_at.".");

            $spell->learned_at(TAEB->turn - 20_001);
        }
        else {
            TAEB->debug("Setting " . $spell->name . "'s learned at to the current turn (".(TAEB->turn)."), was ".$spell->learned_at.".");

            $spell->learned_at(TAEB->turn);
        }
    }
}

1;


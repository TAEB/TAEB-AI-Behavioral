#!/usr/bin/env perl
package TAEB::Knowledge::Spell;
use Moose;

# this will disappear soon
my %level_of = (
    # Attack
    'force bolt' => 1,
    'drain life' => 2,
    'magic missile' => 2,
    'cone of cold' => 4,
    'fireball' => 4,
    'finger of death' => 7,

    # Clerical
    'protection' => 1,
    'create monster' => 2,
    'remove curse' => 3,
    'create familiar' => 6,
    'turn undead' => 6,

    # Divination
    'detect monsters' => 1,
    'light' => 1,
    'detect food' => 2,
    'clairvoyance' => 3,
    'detect unseen' => 3,
    'identify' => 3,
    'detect treasure' => 4,
    'magic mapping' => 5,

    # Enchantment
    'sleep' => 1,
    'confuse monster' => 2,
    'slow monster' => 2,
    'cause fear' => 3,
    'charm monster' => 3,

    # Escape
    'jumping' => 1,
    'haste self' => 3,
    'invisibility' => 4,
    'levitation' => 4,
    'teleport away' => 6,

    # Healing
    'healing' => 1,
    'cure blindness' => 2,
    'cure sickness' => 3,
    'extra healing' => 3,
    'stone to flesh' => 3,
    'restore ability' => 4,

    # Matter
    'knock' => 1,
    'wizard lock' => 2,
    'dig' => 5,
    'polymorph' => 6,
    'cancellation' => 7,
);

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

has fail => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has slot => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

=head2 castable

Can this spell be cast this turn? This does not only take into account spell
age, but also whether you're confused, have enough power, etc.

=cut

sub castable {
    my $self = shift;

    return 0 if $self->forgotten;
    return 0 if $level_of{ $self->name } * 5 > TAEB->power;
    return 1;
}

sub forgotten {
    my $self = shift;
    return TAEB->turn > $self->learned_at + 20_000;
}

1;


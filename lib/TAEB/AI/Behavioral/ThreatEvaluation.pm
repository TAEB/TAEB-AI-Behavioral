package TAEB::AI::Behavioral::ThreatEvaluation;
use Moose;
use TAEB::OO;

# Data class for evaluations of monster threat levels, since it's more
# typo-resistant than a simple hashref.  Monster threat levels depend
# on terrain and buffs, and need to be re-evaluated every turn.  To get
# an evaluation for a monster, ask your friendly local TAEB->ai.

# Is this monster worth spending major resources (consumables and wand
# charges) on?

has spend_major => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

# Is this monster worth spending minor resources (mana and mulchable
# ammunition) on?

has spend_minor => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

# Is this a monster that we want to avoid melee contact with at
# almost any cost?

has avoid_melee => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

__PACKAGE__->meta->make_immutable;

1;


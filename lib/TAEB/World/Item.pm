#!/usr/bin/env perl
package TAEB::World::Item;
use Moose;
use Moose::Util::TypeConstraints;

has appearance => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    trigger  => sub {
        my $self = shift;
        $self->trigger_appearance(@_);
    },
);

has slot => (
    is  => 'rw',
    isa => 'Str',
);

has quantity => (
    is      => 'rw',
    isa     => 'Int',
    default => 1,
);

enum BUC => qw(blessed uncursed cursed unknown);

has buc => (
    is      => 'rw',
    isa     => 'BUC',
    default => 'unknown',
);

has is_greased => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has is_poisoned => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has erosion1 => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has erosion2 => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has is_fooproof => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has partly_used => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has is_diluted => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has partly_eaten => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has enchantment => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

enum ItemClass => qw(gold weapon armor food scroll book potion amulet ring wand tool gem);
has class => (
    is            => 'rw',
    isa           => 'ItemClass',
    documentation => "Armor, weapon, scroll, etc.",
);

has visible_description => (
    is            => 'rw',
    isa           => 'Str',
    documentation => "Smoky potion, mud boots, etc.",
);

has identity => (
    is            => 'rw',
    isa           => 'Str',
    documentation => "Chain mail, long sword, cloak of magic resistance, etc.",
);

has generic_name => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => "called X",
);

has specific_name => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => "named X",
);

has recharges => (
    is      => 'rw',
    isa     => 'Int',
);

has charges => (
    is      => 'rw',
    isa     => 'Int',
);

has is_lit => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has candles_attached => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has is_quivered => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has is_offhand => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has is_laid_by_you => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has is_equipped => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

# check whether this is an artifact, and if so, let the artifact-tracker know
# we've seen it
sub BUILD {
    my $self = shift;

    my $artifact = TAEB::Knowledge::Item::Artifact->artifact($self->appearance)
        or return;
    TAEB::Knowledge::Item::Artifact->seen($self->appearance => 1);
}

=head2 matches (Str|Regexp|CODE) -> Bool

Does the given item look sufficiently like this item?

This is intentionally vague because I don't know what I want yet.

If a coderef is passed in, then C<$_> will be the appearance. The coderef will
also get an argument: the item itself.

=cut

sub matches {
    my $self = shift;
    my $item = shift;

    if (ref($item) eq 'Regexp') {
        return $self->appearance =~ $item;
    }
    elsif (ref($item) eq 'CODE') {
        local $_ = $self->appearance;
        return $item->($self);
    }

    return $self->appearance eq $item;
}

sub trigger_appearance {
    my $self       = shift;
    my $appearance = shift;

    # XXX: there's no way to tell the difference between an item called
    # "foo named bar" and an item called "foo" and named "bar". similarly for
    # an item called "foo (0:1)". so... don't do that!
    my ($slot, $num, $buc, $greased, $poisoned, $ero1, $ero2, $proof, $used,
        $dilute, $eaten, $spe, $item, $call, $name, $recharges, $charges,
        $ncandles, $lit_candelabrum, $lit, $laid, $quiver, $offhand,
        $equipped) = $appearance =~
        m{(?:(\w)\s[+-])?\s*                               # inventory slot
          (an?|the|\d+)\s*                                 # number
          (blessed|(?:un)?cursed)?\s*                      # cursedness
          (greased)?\s*                                    # greasy
          (poisoned)?\s*                                   # poisoned
          ((?:(?:very|thoroughly)\ )?(?:burnt|rusty))?\s*  # erosion 1
          ((?:(?:very|thoroughly)\ )?(?:rotted|corroded))?\s* # erosion 2
          (fixed|(?:fire|rust|corrode)proof)?\s*           # fooproof
          (partly\ used)?\s*                               # candles
          (diluted)?\s*                                    # dilution
          (partly\ eaten)?\s*                              # food
          ([+-]\d+)?\s*                                    # enchantment
          (?:(?:pair|set)\ of)?\s*                         # gloves and boots
          (.*?)\s*                                         # item name
          (?:called\ (.*?))?\s*                            # non-specific name
          (?:named\ (.*?))?\s*                             # specific name
          (?:\((\d+):(-?\d+)\))?\s*                        # charges
          (?:\((no|[1-7])\ candles?(,\ lit|\ attached)\))?\s* # lit candelabrum
          (\(lit\))?\s*                                    # lit
          (\(laid\ by\ you\))?\s*                          # eggs
          (\(in\ quiver\))?\s*                             # quivered
          (\(alternate\ weapon;\ not\ wielded\))?\s*       # off-hand weapon
          (\(.*\))?\s*                                     # equipped
          $                                                # anchor the regex
         }x;

    $num = 1        if $num =~ /[at]/;
    $spe =~ s/^\+// if defined $spe;
    $ncandles = 0   if (defined $ncandles && $ncandles =~ /no/);
    $lit = 1        if (defined $lit_candelabrum && $lit_candelabrum =~ /lit/);
    # XXX: depluralization and japanese name mappings should go here

    $self->slot($slot)                 if defined $slot;
    $self->quantity($num)              if defined $num;
    $self->buc($buc)                   if defined $buc;
    $self->is_greased(1)               if defined $greased;
    $self->is_poisoned(1)              if defined $poisoned;
    if (defined $ero1) {
        $self->erosion1(1);
        $self->erosion1(2)             if $ero1 =~ /very/;
        $self->erosion1(3)             if $ero1 =~ /thoroughly/;
    }
    if (defined $ero2) {
        $self->erosion2(1);
        $self->erosion2(2)             if $ero2 =~ /very/;
        $self->erosion2(3)             if $ero2 =~ /thoroughly/;
    }
    $self->is_fooproof(1)              if defined $proof;
    $self->partly_used(1)              if defined $used;
    $self->is_diluted(1)               if defined $dilute;
    $self->partly_eaten(1)             if defined $eaten;
    $self->enchantment($spe)           if defined $spe;
    if (defined $item) {
        my $class = TAEB::Knowledge::Item->list->{$item};

        if (!$class) {
            TAEB->error("Unable to find '$item' in TAEB::Knowledge::Item. Defaulting to empty string. Good luck.");
            $class = '';
        }

        $self->class('gold')           if $item =~ /gold piece/;
        $self->class('weapon')         if $class eq 'weapon';
        $self->class('armor')          if $class eq 'armor';
        $self->class('food')           if $class eq 'food';
        $self->class('scroll')         if $item =~ /scroll/;
        $self->class('book')           if $item =~ /[bB]ook/;
        $self->class('potion')         if $item =~ /potion/;
        $self->class('amulet')         if $item =~ /[aA]mulet/;
        # this won't catch identified rings, but we need to not have this match
        # 'ring mail'. probably fix this once we have an item db for rings.
        $self->class('ring')           if $item =~ /ring$/;
        $self->class('wand')           if $item =~ /wand/;
        $self->class('tool')           if $class eq 'tool';
        # don't match 'rock mole corpse', etc
        $self->class('gem')            if 0;
    }
    $self->recharges($recharges)       if defined $recharges;
    $self->charges($charges)           if defined $charges;
    $self->candles_attached($ncandles) if defined $ncandles;
    if ($self->class) {
        if ($self->class =~ /weapon|armor|food|tool/) {
            my $class = $self->class;
            $class = uc(substr $class, 0, 1) . substr $class, 1;
            my $list = "TAEB::Knowledge::Item::$class"->list;
            if ($list->{$item}) {
                $self->identity($item);
            }
            else {
                $self->visible_description($item);
            }
        }
        else {
            $self->visible_description($item);
        }
        if (!defined $buc &&
            ($self->class =~ /weapon|wand/ ||
             ($self->class eq 'tool' &&
              defined $self->identity &&
              $self->identity =~ /pick-axe|grappling|unicorn/))) {
            $self->buc('uncursed')     if defined $spe || defined $charges;
        }
    }
    else {
        $self->visible_description($item);
    }
    $self->generic_name($call)         if defined $call;
    $self->specific_name($name)        if defined $name;
    $self->is_lit(1)                   if defined $lit;
    $self->is_quivered(1)              if defined $quiver;
    $self->is_offhand(1)               if defined $offhand;
    $self->is_laid_by_you(1)           if defined $laid;
    $self->is_equipped(1)              if defined $equipped;
}

1;


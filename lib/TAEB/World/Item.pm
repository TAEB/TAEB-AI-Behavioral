#!/usr/bin/env perl
package TAEB::World::Item;
use Moose;

use overload
    q{""} => sub {
        my $self = shift;
        # XXX: get a better item description here
        return sprintf '[%s: %s]', blessed($self), $self->identity;
    };

has raw => (
    is            => 'rw',
    isa           => 'Str',
    documentation => "The raw string NetHack gave us for the item. Don't use it for code, use it only for logging.",
);

has identity => (
    is            => 'rw',
    isa           => 'Str',
    documentation => "Chain mail, long sword, cloak of magic resistance, etc.",
);

has class => (
    is            => 'rw',
    isa           => 'ItemClass',
    default       => 'unknown',
    documentation => "Armor, weapon, scroll, etc.",
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

has is_wielding => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has is_offhand => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has is_quivered => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has cost => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has possibility_tracker => (
    is      => 'ro',
    isa     => 'TAEB::Knowledge::Item',
    lazy    => 1,
    default => sub {
        my $self = shift;
        # XXX: appearance and identity need some kind of change
        TAEB::Knowledge->appearances->{$self->class}{$self->appearance};
    },
    handles => [qw/exclude_possibility has_possibilities possibilities rule_out rule_out_all_but identify_as/],
);

my %japanese_to_english = (
    "wakizashi"      => "short sword",
    "ninja-to"       => "broadsword",
    "nunchaku"       => "flail",
    "naginata"       => "glaive",
    "osaku"          => "lock pick",
    "koto"           => "wooden harp",
    "shito"          => "knife",
    "tanko"          => "plate mail",
    "kabuto"         => "helmet",
    "yugake"         => "leather gloves",
    "gunyoki"        => "food ration",
    "potion of sake" => "potion of booze",
);

sub new_item {
    my $self = shift;
    my $raw  = shift;

    # XXX: there's no way to tell the difference between an item called
    # "foo named bar" and an item called "foo" and named "bar". similarly for
    # an item called "foo (0:1)". so... don't do that!
    my ($slot, $num, $buc, $greased, $poisoned, $ero1, $ero2, $proof, $used,
        $eaten, $dilute, $spe, $item, $call, $name, $recharges, $charges,
        $ncandles, $lit_candelabrum, $lit, $laid, $chain, $quiver, $offhand,
        $wield, $wear, $cost) = $raw =~
        m{(?:(\w)\s[+-])?\s*                               # inventory slot
          (an?|the|\d+)\s*                                 # number
          (blessed|(?:un)?cursed)?\s*                      # cursedness
          (greased)?\s*                                    # greasy
          (poisoned)?\s*                                   # poisoned
          ((?:(?:very|thoroughly)\ )?(?:burnt|rusty))?\s*  # erosion 1
          ((?:(?:very|thoroughly)\ )?(?:rotted|corroded))?\s* # erosion 2
          (fixed|(?:fire|rust|corrode)proof)?\s*           # fooproof
          (partly\ used)?\s*                               # candles
          (partly\ eaten)?\s*                              # food
          (diluted)?\s*                                    # potions
          ([+-]\d+)?\s*                                    # enchantment
          (?:(?:pair|set)\ of)?\s*                         # gloves and boots
          (.*?)\s*                                         # item name
          (?:called\ (.*?))?\s*                            # non-specific name
          (?:named\ (.*?))?\s*                             # specific name
          (?:\((\d+):(-?\d+)\))?\s*                        # charges
          (?:\((no|[1-7])\ candles?(,\ lit|\ attached)\))?\s* # lit candelabrum
          (\(lit\))?\s*                                    # lit
          (\(laid\ by\ you\))?\s*                          # eggs
          (\(chained\ to\ you\))?\s*                       # iron balls
          (\(in\ quiver\))?\s*                             # quivered
          (\(alternate\ weapon;\ not\ wielded\))?\s*       # off-hand weapon
          (\(weapon.*?\))?\s*                              # wielding
          (\((?:being|embedded|on).*?\))?\s*               # wearing
          (?:\(unpaid,\ (\d+)\ zorkmids?\))?\s*            # shops
          $                                                # anchor the regex
         }x;

    $item = $japanese_to_english{$item} || $item;
    $item = TAEB::Spoilers::Item->singular_of->{$item} || $item;

    $num = 1         if $num =~ /[at]/;
    $spe =~ s/^\+//  if defined $spe;
    $ncandles = 0    if (defined $ncandles && $ncandles =~ /no/);
    $lit = 1         if (defined $lit_candelabrum && $lit_candelabrum =~ /lit/);

    my $new_item;
    unless (defined $item) {
        TAEB->warning("Couldn't find the base item type for '$raw'!");
        return;
    }

    my $class = TAEB::Spoilers::Item->type_to_class($item);
    unless (defined $class) {
        TAEB->warning("Unable to find '$item' in TAEB::Spoilers::Item.");
        return;
    }

    my $class_name = ucfirst $class;
    unless (grep { $class_name eq $_ } TAEB::Spoilers::Item->types) {
        TAEB->warning("Items (such as $raw) of class $class are not yet supported.");
        return;
    }

    $new_item = "TAEB::World::Item::$class_name"->new(raw => $raw);

    # XXX: once the EliteBot item identification code gets merged
    # in here, this might have to be changed, but it's good enough
    # for now
    $new_item->identity($item);

    $new_item->buc($buc)                   if defined $buc;
    # XXX: this should go into Spoilers::Item::Tool at some point
    my $is_weaptool = $class eq 'tool' && $item =~ /pick-axe|hook|unicorn/;
    if (!defined $buc &&
        ($class eq 'weapon' || $class eq 'wand' || $is_weaptool)) {
        $new_item->buc('uncursed') if defined $spe || defined $charges;
    }

    $new_item->slot($slot)                 if defined $slot;
    $new_item->quantity($num)              if defined $num;
    $new_item->is_greased(1)               if defined $greased;
    $new_item->is_poisoned(1)              if defined $poisoned;
    if (defined $ero1) {
        $new_item->erosion1(1);
        $new_item->erosion1(2)             if $ero1 =~ /very/;
        $new_item->erosion1(3)             if $ero1 =~ /thoroughly/;
    }
    if (defined $ero2) {
        $new_item->erosion2(1);
        $new_item->erosion2(2)             if $ero2 =~ /very/;
        $new_item->erosion2(3)             if $ero2 =~ /thoroughly/;
    }
    $new_item->is_fooproof(1)              if defined $proof;
    $new_item->is_partly_used(1)           if defined $used;
    $new_item->is_partly_eaten(1)          if defined $eaten;
    $new_item->is_diluted(1)               if defined $dilute;
    $new_item->enchantment($spe)           if defined $spe;
    $new_item->recharges($recharges)       if defined $recharges;
    $new_item->charges($charges)           if defined $charges;
    $new_item->candles_attached($ncandles) if defined $ncandles;
    $new_item->generic_name($call)         if defined $call;
    $new_item->specific_name($name)        if defined $name;
    $new_item->is_lit(1)                   if defined $lit;
    $new_item->is_quivered(1)              if defined $quiver;
    $new_item->is_offhand(1)               if defined $offhand;
    $new_item->is_laid_by_you(1)           if defined $laid;
    $new_item->is_chained_to_you(1)        if defined $chain;
    $new_item->is_wielding(1)              if defined $wield;
    $new_item->is_wearing(1)               if defined $wear;
    $new_item->cost($cost)                 if defined $cost;

    return $new_item;
}

1;


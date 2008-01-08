#!/usr/bin/env perl
package TAEB::World::Item;
use Moose;

has appearance => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    trigger  => sub { shift->can('trigger_appearance') },
);

has slot => (
    is  => 'rw',
    isa => 'Str',
);

has quantity => (
    is      => 'rw',
    isa     => 'Int',
);

has buc => (
    is      => 'rw',
    isa     => 'Str',
);

has is_greased => (
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
);

has enchantment => (
    is      => 'rw',
    isa     => 'Int',
);

# armor, weapon, scroll, etc
has class => (
    is      => 'rw',
    isa     => 'Str',
);

# smoky potion, mud boots, etc
has visible_description => (
    is      => 'rw',
    isa     => 'Str',
);

# chain mail, long sword, cloak of magic resistance, etc
has type => (
    is      => 'rw',
    isa     => 'Str',
);

# called X
has generic_name => (
    is      => 'rw',
    isa     => 'Str',
    default => '',
);

# named X
has specific_name => (
    is      => 'rw',
    isa     => 'Str',
    default => '',
);

has charges => (
    is      => 'rw',
    isa     => 'Int',
);

has max_charges => (
    is      => 'rw',
    isa     => 'Int',
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
    my ($slot, $num, $buc, $grease, $ero1, $ero2, $proof, $spe, $item, $call,
        $name, $charge, $max_charge, $equipped) =~
        m{(?:(\w)\s-)?\s*                                # inventory slot
          (an?|the|\d+)\s*                               # number
          (blessed|(?:un)?cursed)?\s*                    # cursedness
          (greased)?\s*                                  # greasy
          ((?:(?:very|thoroughly) )?burnt|rusty)?\s*     # erosion 1
          ((?:(?:very|thoroughly) )?rotted|corroded)?\s* # erosion 2
          (fixed|(?:fire|rust|corrode)proof)?\s*         # fooproof
          ((?:\+|-)\d+)?\s*                              # enchantment
          (.*?)\s*                                       # item name
          (called .*?)?\s*                               # non-specific name
          (named .*?)?\s*                                # specific name
          (\(\d+:\d+\))?\s*                              # charges
          (\(.*\))?\s*                                   # equipped
         }x;

    $num = 1 if $num =~ /\w/;

    $self->slot($slot)              if defined $slot;
    $self->quantity($num)           if defined $num;
    $self->buc(substr $buc, 0, 1)   if defined $buc;
    $self->is_greased(1)            if defined $greased;
    if (defined $ero1) {
        $self->erosion1(1)
        $self->erosion1(2)          if $ero1 =~ /very/;
        $self->erosion1(3)          if $ero1 =~ /thoroughly/;
    }
    if (defined $ero2) {
        $self->erosion2(1)
        $self->erosion2(2)          if $ero2 =~ /very/;
        $self->erosion2(3)          if $ero2 =~ /thoroughly/;
    }
    $self->is_fooproof(1)           if defined $proof;
    $self->enchantment($spe)        if defined $spe;
    # XXX: handle class, visible_description, and type correctly later when we
    # have some better way to match them
    $self->type($item)              if defined $item;
    $self->generic_name($call)      if defined $call;
    $self->specific_name($name)     if defined $name;
    $self->charges($charge)         if defined $charge;
    $self->max_charges($max_charge) if defined $max_charge;
    $self->is_equipped(1)           if defined $is_equipped;
}

1;


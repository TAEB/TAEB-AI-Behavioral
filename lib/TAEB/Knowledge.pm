#!/usr/bin/env perl
package TAEB::Knowledge;
use TAEB::OO;

use TAEB::Knowledge::Item;
use TAEB::Knowledge::Item::Amulet;
use TAEB::Knowledge::Item::Armor;
use TAEB::Knowledge::Item::Artifact;
use TAEB::Knowledge::Item::Food;
use TAEB::Knowledge::Item::Gem;
use TAEB::Knowledge::Item::Other;
use TAEB::Knowledge::Item::Potion;
use TAEB::Knowledge::Item::Ring;
use TAEB::Knowledge::Item::Scroll;
use TAEB::Knowledge::Item::Spellbook;
use TAEB::Knowledge::Item::Tool;
use TAEB::Knowledge::Item::Wand;
use TAEB::Knowledge::Item::Weapon;
use TAEB::Knowledge::Spell;

has types => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    auto_deref => 1,
    default => sub { [qw/Amulet Armor Food Gem Other Potion Ring Scroll
                         Spellbook Tool Wand Weapon/] },
);

has appearances => (
    isa     => 'HashRef[HashRef[TAEB::Knowledge::Item]]',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $appearances = {};

        for my $type ($self->types) {
            my $class = "TAEB::Spoilers::Item::$type";
            my $knowledgeclass = "TAEB::Knowledge::Item::$type";
            for my $appearance ($class->all_appearances) {
                $appearances->{lc $type}{$appearance} = $knowledgeclass->new(
                    appearance => $appearance,
                    type       => lc($type),
                );
            }
        }

        return $appearances;
    },
);

has appearance_of => (
    isa     => 'HashRef[Str]',
    default => sub { {} },
);

has artifacts => (
    isa     => 'TAEB::Knowledge::Item::Artifact',
    lazy    => 1,
    default => sub { TAEB::Knowledge::Item::Artifact->new },
);

sub msg_discovery {
    my $self       = shift;
    my $identity   = shift;
    my $appearance = shift;

    my ($class) = $identity =~ /^(.*?) (?:of|versus) /
        or return;

    if (lc($class) eq 'scroll') {
        $appearance = "scroll labeled $appearance";
    }
    else {
        $appearance .= " $class";
    }

    my $knowledge = $self->appearances->{lc $class}->{$appearance};
    $knowledge->identify_as($identity) if $knowledge;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


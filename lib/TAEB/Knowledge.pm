#!/usr/bin/env perl
package TAEB::Knowledge;
use MooseX::Singleton;

use TAEB::Knowledge::Item;
use TAEB::Knowledge::Item::Amulet;
use TAEB::Knowledge::Item::Armor;
use TAEB::Knowledge::Item::Food;
use TAEB::Knowledge::Item::Gem;
use TAEB::Knowledge::Item::Potion;
use TAEB::Knowledge::Item::Ring;
use TAEB::Knowledge::Item::Scroll;
use TAEB::Knowledge::Item::Spellbook;
use TAEB::Knowledge::Item::Tool;
use TAEB::Knowledge::Item::Wand;
use TAEB::Knowledge::Item::Weapon;

has types => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    auto_deref => 1,
    default => sub { [qw/Amulet Armor Food Gem Potion Ring Scroll Spellbook
                         Tool Wand Weapon/] },
);

has appearances => (
    is      => 'rw',
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
    is      => 'rw',
    isa     => 'HashRef[Str]',
    default => sub { {} },
);

sub msg_discovery {
    my $self       = shift;
    my $identity   = shift;
    my $appearance = shift;

    # XXX: DOY SEND HELP
    my ($class) = $identity =~ /^(.*?) of /;
    if (lc($class) eq 'scroll') {
        $appearance = "scroll labeled $appearance";
    }
    else {
        $appearance .= " $class";
    }

    my $knowledge = $self->appearances->{lc $class}->{$appearance};
    $knowledge->identify_as($identity) if $knowledge;
}

1;


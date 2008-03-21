#!/usr/bin/env perl
package TAEB::World::Monster;
use TAEB::OO;
use TAEB::Util ':colors';
use String::Koremutake;

has id => (
    is      => 'ro',
    isa     => 'Str',
    default => sub {
        my $k = String::Koremutake->new;
        return $k->integer_to_koremutake(int(rand(2**31)));
    },
);

has tile => (
    isa      => 'TAEB::World::Tile',
    weak_ref => 1,
);

has name => (
    isa => 'Str',
);

has peaceful => (
    isa     => 'Bool',
    default => 0,
    trigger => sub {
        return unless $_[1];
        $_[0]->hostile(0);
    },
);

has tame => (
    isa     => 'Bool',
    default => 0,
    trigger => sub {
        return unless $_[1];
        $_[0]->peaceful(1);
    },
);

has hostile => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
    trigger => sub {
        return unless $_[1];
        $_[0]->peaceful(0);
        $_[0]->tame(0);
    },
);

sub new_monster {
    my $self  = shift;
    my $glyph = shift;
    my $color = shift;
    my $name  = shift;

    my $monster;

    if (defined($name)) {
        my $mon = TAEB::Spoilers::Monster->monster($name);
        if ($mon) {
            return TAEB::World::Monster->new($mon);
        }
        my ($priest) = $name =~ /^((?:arch |high )?priest) of/;
        if ($priest) {
            $mon = TAEB::Spoilers::Monster->monster($name);
            my %mon = %$mon;
            $mon{id} = $name;
            return TAEB::World::Monster->new(%mon);
        }
        elsif ($glyph eq '@' && $color eq COLOR_WHITE) {
            # better way to identify shopkeepers?
            $mon = TAEB::Spoilers::Monster->monster('shopkeeper');
            my %mon = %$mon;
            $mon{id} = $name;
            return TAEB::World::Monster->new(%mon);
        }
    }
    else {
        my %search;
        $search{glyph} = $glyph if defined $glyph;
        $search{color} = $color if defined $color;
        my %result = TAEB::Spoilers::Monster->search(%search);
        my @keys = keys %result;
        if (@keys == 1) {
            return TAEB::World::Monster->new($result{$keys[0]});
        }
        return undef;
    }

    return undef;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


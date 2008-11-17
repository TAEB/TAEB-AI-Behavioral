#!/usr/bin/env perl
package TAEB::AI::Behavior::Spellbook;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) && $_->difficult < TAEB->level } TAEB->inventory->items;
    return URG_NONE unless @items;

    my $item = shift @items;

    $self->currently("Reading a spellbook");
    $self->do(read => item => $item);

    return URG_UNIMPORTANT;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return 0 if $item->price;
    return 0 unless $item->match(class => 'spellbook');
    return 1 if $item->match(identity => undef);
    return 0 if TAEB->knows_spell($item->spell);

    return 1;
}

sub urgencies {
    return {
       URG_UNIMPORTANT, "reading a spellbook",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


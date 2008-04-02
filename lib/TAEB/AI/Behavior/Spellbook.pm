#!/usr/bin/env perl
package TAEB::AI::Behavior::Spellbook;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) } TAEB->inventory->items;
    return 0 unless @items;

    my $item = shift @items;
    my $pt = $item->possibility_tracker;

    $self->currently("reading a spellbook");
    $self->do(read => item => $item);

    return 100;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return if defined($item->identity);

    if ($item->class eq 'spellbook') {
        return 1;
    }

    return;
}

sub urgencies {
    return {
       100 => "reading a spellbook",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


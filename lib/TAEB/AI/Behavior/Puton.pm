#!/usr/bin/perl
package TAEB::AI::Behavior::Puton;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) && !$_->is_wearing(1); } 
                     TAEB->inventory->items;

    return 0 unless @items;

    my $item = shift @items;

    $self->do(puton => item => $item);
    $self->currently("Putting on a ring");
    return 100;
}

sub pickup {
    my $self = shift;
    my $item = shift;
    
    return $item->match(identity => "ring of slow digestion");
}

sub urgencies {
    return {
        100 => "Putting on a ring",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


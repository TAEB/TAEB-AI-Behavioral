#!/usr/bin/env perl
package TAEB::AI::Behavior::AcquireMithril;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

# I wonder how much of a difference this'll make to the score

sub prepare {
    my $self = shift;

    my $item = TAEB->find_item(qr/mithril/) or return 0;

    # Yeah, so I'm lazy.
    grep { TAEB->role eq $_ } qw/Hea Tou Val/ or return 0;

    return 0 if $item->is_wearing
             || $item->buc eq 'cursed';

    $self->currently("Putting on mithril.");
    $self->do(wear => item => $item);
    return 100;
}

sub drop {
    my $self = shift;
    my $item = shift;

    return if $item->appearance !~ /mithril/
           || $item->buc ne 'cursed';

    TAEB->debug("Yes, I want to drop $item because it is cursed.");
    return 1;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return unless grep { TAEB->senses->role } qw/Hea Tou Val/;

    return if $item->appearance !~ /mithril/
           || $item->buc eq 'cursed'
           || TAEB->find_item(qr/mithril/) ;

    TAEB->debug("Yes, I want to pick up $item because it is mithril.");
    return 1;
}

sub urgencies {
    return {
        100 => "putting on mithril",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


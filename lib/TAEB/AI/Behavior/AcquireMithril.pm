#!/usr/bin/env perl
package TAEB::AI::Behavior::AcquireMithril;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

# I wonder how much of a difference this'll make to the score

sub prepare {
    my $self = shift;

    my $item = TAEB->find_item(qr/mithril/) or return URG_NONE;

    # Yeah, so I'm lazy.
    grep { TAEB->role eq $_ } qw/Hea Tou Val/ or return URG_NONE;

    return URG_NONE if $item->match(is_wearing => 1) ||
                       $item->match(buc => 'cursed') ||
                       $item->price;

    $self->currently("Putting on mithril.");
    $self->do(wear => item => $item);
    return URG_UNIMPORTANT;
}

sub drop {
    my $self = shift;
    my $item = shift;

    return if $item->match(not_appearance => qr/mithril/) ||
              $item->match(not_buc => 'cursed');

    TAEB->debug("Yes, I want to drop $item because it is cursed.");
    return 1;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return unless grep { TAEB->role } qw/Hea Tou Val/;

    return if $item->match(not_appearance => qr/mithril/) ||
              $item->match(buc => 'cursed') ||
              TAEB->find_item(qr/mithril/);

    TAEB->debug("Yes, I want to pick up $item because it is mithril.");
    return 1;
}

sub urgencies {
    return {
        URG_UNIMPORTANT, "putting on mithril",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


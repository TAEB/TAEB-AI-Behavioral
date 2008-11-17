#!/usr/bin/env perl
package TAEB::AI::Behavior::FixHunger;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    if (TAEB->can_pray      &&
        TAEB->nutrition < 2 &&
        TAEB->current_tile->type ne 'altar') { # XXX: Should check if altar is coaligned.
        $self->do("pray");
        $self->currently("Praying for food.");
        $self->urgency('critical');
        return;
    }

    if (TAEB->nutrition < 200 && TAEB::Action::Eat->any_food) {
        $self->do(eat => item => 'any');
        $self->currently("Eating food.");
        $self->urgency('important');
        return;
    }
}

sub urgencies {
    return {
        critical  => "praying for food, while fainting",
        important => "eating food because nutrition is < 200",
    },
}

sub pickup {
    my $self = shift;
    my $item = shift;
    return 0 unless $item->match(weight => sub { shift() < 100 });
    return TAEB::Spoilers::Item::Food->should_eat($item);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


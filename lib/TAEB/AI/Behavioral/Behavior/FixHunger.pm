package TAEB::AI::Behavioral::Behavior::FixHunger;
use TAEB::OO;
use List::Util 'sum';
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    # if we're on an altar, demand it be of our alignment
    my $altar_ok = TAEB->current_tile->type ne 'altar'
                || TAEB->current_tile->align eq TAEB->align;

    if (TAEB->can_pray && TAEB->nutrition < 2 && $altar_ok) {
        $self->do("pray");
        $self->currently("Praying for food.");
        $self->urgency('critical');
        return;
    }

    return if TAEB->nutrition >= 200;

    my @edible_items = TAEB::Action::Eat->edible_items;
    return unless @edible_items;

    my ($choice, $priority) = ('any', -1000);
    for my $item (@edible_items) {
        # XXX: avoid eating carrots and other beneficial items
        # XXX: prefer floor food
    }

    $self->do(eat => item => $choice);
    $self->currently("Eating food.");
    $self->urgency('important');
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return 0 unless $item->type eq 'food';

    # don't pick up rottable corpses.
    return 0 if defined $item->subtype
             && $item->subtype eq 'corpse'
             && $item->maybe_rotted == 0;

    # XXX: consider food (nutrition / weight) and current load
    return $item->is_safely_edible;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


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

sub urgencies {
    return {
        critical  => "praying for food, while fainting",
        important => "eating food because nutrition is < 200",
    },
}

sub good_food {
    my $item = shift;
    my $great = shift;

    return 0 unless $item->match(weight => sub { $_ < 100 });
    return 0 unless $item->is_safely_edible;
    return 0 if $great && $item->weight > (40 * $item->nutrition);

    return 1;
}

sub good_inv_food {
    my $great = shift;
    return grep { good_food($_, $great) } TAEB->inventory->items;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return 0 unless $item->type eq 'food';

    # don't pick up corpses. XXX: lichens and lizards?
    return 0 if $item->subtype eq 'corpse';

    # XXX: consider food (nutrition / weight) and current load
    return $item->is_safely_edible;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


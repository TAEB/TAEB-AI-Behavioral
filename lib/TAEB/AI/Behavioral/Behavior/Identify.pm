package TAEB::AI::Behavioral::Behavior::Identify;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) && $_->price == 0 }
                TAEB->inventory->items;
    return unless @items;

    my $item = shift @items;
    my $pt = $item->possibility_tracker;

    return unless TAEB->can_engrave
               && $pt->can('engrave_useful')
               && $pt->engrave_useful
               && $item->match(price => 0);

    if (TAEB->current_tile->engraving eq '') {
        $self->do(engrave => item => '-');
        $self->currently("Prepping for engrave-id by dusting");
        $self->urgency('unimportant');
        return;
    }

    $self->do(engrave => item => $item);
    $self->currently("Engrave identifying a wand");
    $self->urgency('unimportant');
    return;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    # we only know how to handle wands
    if ($item->match(class => 'wand', identity => undef)) {
        return 1 if $item->possibility_tracker->engrave_useful;
    }

    return 0;
}

sub urgencies {
    return {
        unimportant => "engrave identifying a wand",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


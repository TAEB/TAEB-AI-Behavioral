package TAEB::AI::Behavioral::Behavior::Identify;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) && $_->cost == 0 }
                TAEB->inventory;
    return unless @items;

    my $item = shift @items;
    my $tracker = $item->tracker;

    return unless TAEB::Action::Engrave->is_advisable
               && $tracker->can('engrave_useful')
               && $tracker->engrave_useful
               && $item->match(cost => 0);

    if (TAEB->current_tile->engraving eq '') {
        $self->do(engrave => engraver => '-');
        $self->currently("Prepping for engrave-id by dusting");
        $self->urgency('unimportant');
        return;
    }

    $self->do(engrave => engraver => $item);
    $self->currently("Engrave identifying a wand");
    $self->urgency('unimportant');
    return;
}

use constant max_urgency => 'unimportant';

sub pickup {
    my $self = shift;
    my $item = shift;

    # we only know how to handle wands
    if ($item->match(type => 'wand', identity => undef)) {
        return 1 if $item->tracker->engrave_useful;
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;

1;


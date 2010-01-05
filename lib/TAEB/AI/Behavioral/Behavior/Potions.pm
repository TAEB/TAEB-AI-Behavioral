package TAEB::AI::Behavioral::Behavior::Potions;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) } TAEB->inventory;
    return unless @items;

    my $item = shift @items;

    $self->currently("quaffing a beneficial potion");
    $self->do(quaff => from => $item);
    $self->urgency('unimportant');
}

use constant max_urgency => 'unimportant';

sub pickup {
    my $self = shift;
    my $item = shift;

    return 1 if $item->match(identity => 'potion of gain ability');
    return 1 if $item->match(identity => 'potion of gain level');
    return 0;
}

__PACKAGE__->meta->make_immutable;

1;


package TAEB::AI::Behavioral::Behavior::Genocide;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my $scroll = TAEB->has_item(identity => 'scroll of genocide');

    return unless $scroll;

    $self->do(read => scroll => $wand);
    $self->currently("Zapping a scroll of genocide");
    $self->urgency('unimportant');
}

use constant max_urgency => 'unimportant';

sub pickup {
    my $self = shift;
    my $item = shift;

    return 0 unless $item->match(identity => 'scroll of genocide');

    return 1;
}

__PACKAGE__->meta->make_immutable;

1;


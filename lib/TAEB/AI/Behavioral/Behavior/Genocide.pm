package TAEB::AI::Behavioral::Behavior::Genocide;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my $scroll = TAEB->has_item(identity => 'scroll of genocide');

    return unless $scroll;

    $self->do(read => item => $scroll);
    $self->currently("Reading a scroll of genocide");
    $self->urgency('important');
}

use constant max_urgency => 'important';

sub pickup {
    my $self = shift;
    my $item = shift;

    return 0 unless $item->match(identity => 'scroll of genocide');

    return 1;
}

__PACKAGE__->meta->make_immutable;

1;


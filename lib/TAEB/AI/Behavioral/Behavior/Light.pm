package TAEB::AI::Behavioral::Behavior::Light;
use Moose;
use TAEB::OO;
use TAEB::Util 'any';
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my @lamps = TAEB->inventory->find(identity => /lamp|lantern/);
    return unless @lamps;
    return if any { $_->is_lit } @lamps;

    $self->do(apply => item => $lamps[0]);
    $self->currently("Lighting up a lamp");
    $self->urgency('normal');
}

use constant max_urgency => 'normal';

sub pickup {
    my $self = shift;
    my $item = shift;

    $item->match(identity => qr/lamp|lantern/);
}

__PACKAGE__->meta->make_immutable;

1;


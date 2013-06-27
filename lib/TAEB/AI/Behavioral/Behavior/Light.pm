package TAEB::AI::Behavioral::Behavior::Light;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my @lamps = TAEB->inventory->find(identity => qr/lamp|lantern/);
    @lamps = grep { !$_->is_lit && !$_->cost && $_->has_oil } @lamps;
    return unless @lamps;

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


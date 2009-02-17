package TAEB::AI::Behavioral::Behavior::Wish;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my $wand = TAEB->has_item(identity => 'wand of wishing',
                              charges  => [undef, sub { $_ > 0 }]);

    return unless $wand;

    $self->do(zap => wand => $wand);
    $self->currently("Zapping a wand of wishing");
    $self->urgency('unimportant');
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return 0 unless $item->match(identity => 'wand of wishing');

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


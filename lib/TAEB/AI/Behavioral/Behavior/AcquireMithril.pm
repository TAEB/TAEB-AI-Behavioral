package TAEB::AI::Behavioral::Behavior::AcquireMithril;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

# I wonder how much of a difference this'll make to the score

sub prepare {
    my $self = shift;

    my $item = TAEB->has_item(qr/mithril/) or return;

    # Yeah, so I'm lazy.
    grep { TAEB->role eq $_ } qw/Hea Tou Val/ or return;

    return if $item->match(is_wearing => 1)
           || $item->match(buc => 'cursed')
           || $item->cost;

    $self->currently("Putting on mithril.");
    $self->do(wear => item => $item);
    $self->urgency('unimportant');
}

sub drop {
    my $self = shift;
    my $item = shift;

    return if $item->match('!appearance' => qr/mithril/)
           || $item->match('!buc' => 'cursed');

    TAEB->log->behavior("Yes, I want to drop $item because it is cursed.");
    return 1;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return unless grep { TAEB->role } qw/Hea Tou Val/;

    return if $item->match('!appearance' => qr/mithril/)
           || $item->match(buc => 'cursed')
           || TAEB->has_item(qr/mithril/);

    TAEB->log->behavior("Yes, I want to pick up $item because it is mithril.");
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

package TAEB::AI::Behavioral::Behavior::Puton;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) && !$_->is_worn; }
                     TAEB->inventory->items;

    return unless @items;

    my $item = shift @items;

    $self->do(puton => item => $item);
    $self->currently("Putting on a ring");
    $self->urgency('unimportant');
}

sub pickup {
    my $self = shift;
    my $item = shift;
    
    return $item->match(identity => "ring of slow digestion");
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


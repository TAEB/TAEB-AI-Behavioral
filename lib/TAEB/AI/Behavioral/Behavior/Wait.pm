package TAEB::AI::Behavioral::Behavior::Wait;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    $self->do('search', iterations => 50);
    $self->currently('Waiting');
    $self->urgency('fallback');
}

__PACKAGE__->meta->make_immutable;

1;



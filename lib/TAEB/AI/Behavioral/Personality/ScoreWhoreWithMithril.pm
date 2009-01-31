package TAEB::AI::Behavioral::Personality::ScoreWhoreWithMithril;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Personality::ScoreWhore';

after sort_behaviors => sub {
    my $self = shift;

    $self->add_behavior('AcquireMithril', before => 'DipForExcalibur');
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


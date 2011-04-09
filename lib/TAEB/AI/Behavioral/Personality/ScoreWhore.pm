package TAEB::AI::Behavioral::Personality::ScoreWhore;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Personality::Explorer';

=head1 NAME

TAEB::AI::Behavioral::Personality::ScoreWhore - milk each dungeon level for as long as possible

=head1 DESCRIPTION

This personality will avoid descending until its experience level is greater
than its dungeon level, or it spent 1000 turns on the current level.

This is an example of shifting the weight of a behavior around.

=cut

after sort_behaviors => sub {
    my $self = shift;

    # Descend at a very leisurely pace
    $self->remove_behavior('Descend');
    if (TAEB->level > TAEB->z || TAEB->current_level->turns_spent_on >= 1000) {
        $self->add_behavior('Descend', before => 'Search');
    }
    else {
        $self->add_behavior('Descend', after => 'Search');
    }
};

__PACKAGE__->meta->make_immutable;

1;


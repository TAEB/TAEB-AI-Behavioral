package TAEB::AI::Behavioral::Personality::Descender;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Personality::Explorer';

=head1 NAME

TAEB::AI::Behavioral::Personality::Descender - descend as quickly as sanely possible

=cut

after sort_behaviors => sub {
    my $self = shift;

    $self->remove_behavior('Descend');
    $self->add_behavior('Descend', before => 'Projectiles');
};

__PACKAGE__->meta->make_immutable;

1;


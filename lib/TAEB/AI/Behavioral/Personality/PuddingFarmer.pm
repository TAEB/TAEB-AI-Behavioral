package TAEB::AI::Behavioral::Personality::PuddingFarmer;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Personality::Explorer';

=head1 NAME

TAEB::AI::Behavioral::Personality::PuddingFarmer - the high score is OURS!

=cut

after sort_behaviors => sub {
    my $self = shift;

    $self->add_behavior('GetPudding', before => 'Doors');
};

around pickup => sub {
    my $orig = shift;
    my $self = shift;
    my $item = shift;

    return 1 if $item->match(identity =>
                             ['wand of fire', # engraving
                              'ring of slow digestion']); # sustenance

    return $orig->($self, $item, @_);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


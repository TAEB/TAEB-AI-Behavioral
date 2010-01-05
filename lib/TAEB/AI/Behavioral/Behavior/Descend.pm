package TAEB::AI::Behavioral::Behavior::Descend;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior::GotoTile';

has stairsdown => (
    traits     => ['Array'],
    writer     => '_set_stairsdown',
    isa        => 'ArrayRef[TAEB::World::Tile]',
    default    => sub { [] },
    handles    => {
        stairsdown     => 'elements',
        num_stairsdown => 'count',
    }
);

around stairsdown => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig unless @_;
    return $self->_set_stairsdown(@_);
};

sub correct_stairs {
    my $self = shift;
    my $tile = shift;

    # not stairs down!
    return 0 unless $tile->type eq 'stairsdown';

    # we only have one choice
    return 1 if $self->num_stairsdown == 1;

    # here we have multiple choices and this one is the one we want to avoid.
    # no thank you
    my $config = TAEB->config->get_ai_config || {};
    if ($config->{avoid_branch}) {
        return 0 if $tile->other_side
                 && $tile->other_side->known_branch
                 && $tile->other_side->branch eq $config->{avoid_branch};
    }

    return 1;
}

sub match_tile {
    my ($self, $tile) = @_;
    $self->correct_stairs($tile) ? (['descend'], 'Descending', 'fallback')
                                 : undef
}

sub first_pass {

    return if TAEB->is_levitating;

    my @stairsdown = TAEB->current_level->has_type('stairsdown');
    shift->stairsdown(\@stairsdown);
    return @stairsdown;
}

use constant tile_description => 'the downstairs';
use constant using_urgency    => 'descending';

use constant max_urgency => 'fallback';

__PACKAGE__->meta->make_immutable;

1;


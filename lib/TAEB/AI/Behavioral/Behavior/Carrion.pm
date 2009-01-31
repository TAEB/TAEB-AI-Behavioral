package TAEB::AI::Behavioral::Behavior::Carrion;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior::GotoTile';

sub want_to_eat {
    my ($self, $item, $distance) = @_;

    return 0 unless $item->subtype eq 'corpse';
    return 1 if $item->is_safely_edible(distance => $distance);

    my $unihorn = TAEB->has_item(
        identity => "unicorn horn",
        buc      => [qw/blessed uncursed/],
    );

    # Don't bother eating food that is clearly rotten, and don't risk it
    # without a known-uncursed unihorn
    return 0 if $item->would_be_rotted > ($unihorn ? 0 : -1);

    if (!$unihorn) {
        # Don't inflict very bad conditions

        return 0 if $item->hallucination;
        return 0 if $item->poisonous && !TAEB->senses->poison_resistant;
    }

    return 1 if $item->beneficial_to_eat
             && $item->nutrition + TAEB->nutrition < 2000;

    return 1 if TAEB->nutrition < 995;

    return 0;
}

sub first_pass {
    my $self = shift;

    grep { $self->want_to_eat($_, 0) } TAEB->current_level->items;
}

sub match_tile {
    my ($self, $tile, $path) = @_;
    my $distance = length $path;

    my @yummy = grep { $self->want_to_eat($_, $distance) } $tile->items;

    if (@yummy) {
        return [eat => item => $yummy[0]->identity],
            "eating a " . $yummy[0]->identity;
    } else {
        return undef;
    }
}

sub tile_description { "a corpse" }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


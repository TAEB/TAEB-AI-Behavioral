package TAEB::AI::Behavioral::Behavior::Carrion;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior::GotoTile';

sub want_to_eat {
    my ($self, $item, $distance) = @_;

    return 0 unless $item->match(subtype => 'corpse');

    my $unihorn = TAEB->has_item(
        identity => "unicorn horn",
        buc      => [qw/blessed uncursed/],
    );

    return 0 unless $item->is_safely_edible(
        distance => $distance,
        unihorn  => $unihorn,
    );

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


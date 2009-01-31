package TAEB::AI::Behavioral::Behavior::Carrion;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior::GotoTile';

sub want_to_eat {
    my ($self, $item, $distance) = @_;

    return 0 unless $item->subtype eq 'carrion';
    my $rotted = $item->maybe_rotted(TAEB->turn +
                                     ($distance * TAEB->speed / 12));
    my $unihorn = TAEB->has_item(
        identity => "unicorn horn",
        buc      => [qw/blessed uncursed/],
    );

    # Don't bother eating food that is clearly rotten, and don't risk it
    # without a known-uncursed unihorn
    return 0 if ($rotted > ($unihorn ? 0 : -1));

    # No food suicides
    for my $foot (qw/die lycanthropy petrify polymorph slime/) {
        return 0 if $item->$foot();
    }

    if (!$unihorn) {
        # Don't inflict very bad conditions

        return 0 if $item->hallucination;
        return 0 if $item->poisonous && !TAEB->senses->poison_resistant;
    }

    return 0 if $item->stun;
    return 0 if $item->acidic && TAEB->hp <= 15;

    # worst case is Str-dependant and usuallly milder
    return 0 if $item->poisonous && !TAEB->senses->poison_resistant
             && TAEB->hp <= 29;

    return 0 if ($item->cannibal eq TAEB->race || $item->aggravate)
             && TAEB->race ne 'Orc'
             && TAEB->role ne 'Cav';

    return 0 if $item->speed_toggle && TAEB->is_fast;
    #return 0 if $item->teleportitis && !$item->teleport_control;

    my $good = 0;

    for my $nice (qw/disintegration_resistance energy gain_level heal
            intelligence invisibility reanimates sleep_resistance speed_toggle
            strength telepathy teleport_control teleportitis/) {
        $good = 1 if $item->$nice();
    }

    for my $resist (qw/shock poison fire cold sleep disintegration/) {
        my $prop = "${resist}_resistance";
        my $res  = "${resist}_resistant";
        $good = 1 if $item->$prop() && !TAEB->$res();
    }

    return 1 if $good && ($item->nutrition + TAEB->nutrition < 2000);

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


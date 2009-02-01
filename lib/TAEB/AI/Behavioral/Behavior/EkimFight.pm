package TAEB::AI::Behavioral::Behavior::EkimFight;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    if (TAEB->is_engulfed) {
        $self->do(melee => direction => 'j');
        $self->currently("Attacking our engulfer.");
        $self->urgency('normal');
        return;
    }

    return unless TAEB->current_level->has_enemies;

    # look for the nearest tile with a monster
    # XXX: this must be a walking distance, not teleport or something
    my $path = TAEB::World::Path->first_match(
        sub { shift->has_enemy },
        through_unknown => 1,
    );

    # there's a monster on the map, but we don't know how to reach it
    return unless $path && $path->path;

    # monster is far enough away to be insignificant
    return if length($path->path) > 8;

    # if we have fewer than three Elbereths, write another
    if (TAEB->can_engrave && TAEB->elbereth_count < 3) {
        $self->write_elbereth;
        $self->currently("Writing Elbereth in preparation for combat.");
        $self->urgency('unimportant');
        return;
    }

    # if there's an adjacent monster, attack it
    my $found_monster;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        if ($tile->has_enemy) {
            $self->do(melee => direction => $dir);
            $self->currently("Attacking a " . $tile->glyph);
            $found_monster = 1;
        }
    });
    return $self->urgency('normal') if $found_monster;

    return unless TAEB->can_engrave;

    # not sure what happened, so just write Elbereth
    $self->write_elbereth;
    $self->currently("Writing extra Elbereths.");
    $self->urgency('unimportant');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


package TAEB::AI::Behavioral::Behavior::Melee;
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

    return unless grep { $_->is_meleeable } TAEB->current_level->has_enemies;

    # if there's an adjacent monster, attack it
    my $found_monster;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        if ($tile->has_enemy && $tile->monster->is_meleeable) {
            my $action = 'melee';
            if ($tile->monster->is_ghost && TAEB->level < 10
                                         && !TAEB->has_item('Excalibur')) {
                $action = 'kick';
            }

            $self->do($action => direction => $dir);
            $self->currently("Attacking a " . $tile->glyph);
            $found_monster = 1;
        }
    });
    return $self->urgency('normal') if $found_monster;

    # look for the nearest tile with a monster
    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;

            return $tile->has_enemy
                && $tile->monster->is_meleeable
                && !$tile->monster->is_seen_through_warning
        },
        through_unknown => 1,
        why => "Melee/Close",
    );

    $self->if_path($path =>
        sub { "Heading towards a " . $path->to->glyph . " monster" },
        'unimportant');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


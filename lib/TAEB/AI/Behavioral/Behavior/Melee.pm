package TAEB::AI::Behavioral::Behavior::Melee;
use Moose;
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

    if (my $nonmeleeable_dir = $self->handle_block_by_nonmeleeable) {
        $self->do(melee => direction => $nonmeleeable_dir);
        $self->currently("Attacking a non-meleeable monster due to being surrounded");
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
            $self->currently("Attacking a " . $tile->monster->glyph);
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
        include_endpoints => 1,
    );

    $self->if_path($path =>
        sub { "Heading towards a " . $path->to->monster->glyph . " monster" },
        'unimportant');
}

use constant max_urgency => 'normal';

# XXX: this does nothing yet, tis a sketch
sub veto_eat {
    my $self    = shift;
    my $action  = shift;

    return 0 if TAEB->nutrition < 50; # we're really starving

    my $found_monster;
    TAEB->each_adjacent(sub {
        my $tile = shift;
        $found_monster = 1 if $tile->has_enemy
                           && $tile->monster->is_meleeable;
                           # XXX: likely to leave a corpse?
    });

    return $found_monster;
}

# handle_block_by_nonmeleeable detects situations where we are completely
# blocked by non-meleeable monsters like the following:
#
#         ###e@
#             e
#             #
#
# This will not only attack floating eyes, but also blue jellies and other
# non-meleeable monsters, but that's probably the right answer anyway.
sub handle_block_by_nonmeleeable {
    my $walkable     = 0;
    my $meleeable    = 0;
    my $nonmeleeable = 0;
    my $dir;

    # check for non-meleeable monsters blocking us off completely
    TAEB->each_adjacent(sub {
        my ($tile, $d) = @_;
        my $monster = $tile->monster;

        $walkable++ if $tile->is_walkable;
        if ($monster) {
            if ($monster->is_meleeable) {
                $meleeable++;
            }
            elsif ($monster->is_enemy) {
                $nonmeleeable++;
                $dir = $d;
            }
        }
    });

    return unless $walkable == 0 && $meleeable == 0 && $nonmeleeable > 0;

    return $dir;
}

__PACKAGE__->meta->make_immutable;

1;


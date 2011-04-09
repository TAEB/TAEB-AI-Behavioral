package TAEB::AI::Behavioral::Behavior::Chokepoint;
use Moose;
use TAEB::OO;
use TAEB::Util 'vi2delta', 'angle';
extends 'TAEB::AI::Behavioral::Behavior';

#    .|  We look at a direction as being suitible for running to if it
#   ...  lacks interesting monsters in the inner quadrant, but has a
# @...|  usable chokepoint.  No pathfinding is needed, because we will
#   ..|  just run this again next round, and we do not intend to use
#    .|  chokepoints outside LOS for informational reasons.

#   ..    .   .
# @..|  @.|  @
#   .|    |

# Of course, it has to be a _good_ chokepoint.  We answer that by saying
# it has less walkable neighbors than we do now.

# A quadrant is specified as the intersection of half-planes defined by linear
# functions.

sub vulnerability {
    my ($self, $dir, $tile) = @_;

    # Always try to fight on stairs
    return -1 if $tile->type eq 'stairsup';

    return 99 if !$tile->is_walkable;

    my $score = 0;

    my @enemies = grep { $_->in_los } TAEB->current_level->has_enemies;

    $score += $tile->grep_adjacent(sub {
        my ($tile2, $dir2) = @_;

        # Ignore back directions to reduce the likelyhood of self-cornering.
        $tile2->is_walkable || angle($dir2, $dir) <= 1;
    });

    if ($score > @enemies) { $score = @enemies; }

    # Or on an E-able square, if the monsters aren't E-ignorers
    if (!grep { !$_->respects_elbereth } @enemies) {
        $score += 5 if !$tile->is_engravable;
    }

    $score;
}

sub useful_dir {
    my ($self, $dir) = @_;
    my ($dx, $dy) = vi2delta $dir;
    my $choke = 0;

    my $cut = $self->vulnerability($dir, TAEB->current_tile);

    TILE: for my $tdy (-7 .. 7) {
        for my $tdx (-7 .. 7) {
            my $tile = TAEB->current_level->at(TAEB->x + $tdx, TAEB->y + $tdy);

            next unless $tile;
            next unless $tile->in_los;
            next unless $tdx * ( $dx - $dy) + $tdy * ( $dx + $dy) > 0;
            next unless $tdx * ( $dx + $dy) + $tdy * (-$dx + $dy) > 0;

            my $vul = $self->vulnerability($dir, $tile);

            if ($self->vulnerability($dir, $tile) < $cut && !$choke) {
                TAEB->log->behavior("Found a useful $cut -> $vul ($dir) move (" .
                    ($tile->x - TAEB->x) . "," . ($tile->y - TAEB->y) . ")");
                $choke = 1;
            }

            if ($tile->has_enemy) {
                TAEB->log->behavior("A monster blocks ($dir)");
                return 0;
            }
        }
    }

    return 0 unless $choke;

    my $to = TAEB->current_level->at_direction($dir);

    return 0 unless defined $to
               && $to->is_walkable
               && !$to->has_monster
               && $to->type ne 'trap';

    return 0 if (TAEB->current_tile->type eq 'opendoor'
            || $to->type eq 'opendoor')
           && $dir =~ /[yubn]/;

    TAEB->log->behavior("($dir) is useful!");
    return 1;
}

sub prepare {
    my $self = shift;

    my @enemies = grep { $_->in_los && $_->distance < 9 }
        TAEB->current_level->has_enemies;

    # Useless in one-on-one fights
    return if @enemies <= 1;

    # Useless when fighting peacefuls
    return unless grep { $_->will_chase } @enemies;

    return if TAEB::Action::Move->is_impossible;

    my @dirs = grep { $self->useful_dir($_) } qw/h j k l y u b n/;

    if (@dirs) {
        $self->do(move => direction => $dirs[0]);
        $self->currently("Running for a chokepoint");
        $self->urgency('normal');
    }
}

__PACKAGE__->meta->make_immutable;

1;


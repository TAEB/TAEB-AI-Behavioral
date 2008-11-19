#!/usr/bin/env perl

package TAEB::AI::Behavior::Chokepoint;
use TAEB::OO;
use TAEB::Util 'vi2delta';
extends 'TAEB::AI::Behavior';

#    .|  We look at a direction as being suitible for running to if it
#   ...  lacks interesting monsters in the inner quadrant, but has a
# @...|  usable chokepoint.  No pathfinding is needed, because we will
#   ..|  just run this again next round, and we do not intend to use
#    .|  chokepoints outside LOS for informational reasons.

#   ..    .   .
# @..|  @.|  @
#   .|    |

# a quadrant is specified as the intersection of half-planes defined by linear
# functions

sub useful_dir {
    my ($self, $los, $dir) = @_;
    my ($dx, $dy) = @$dir;
    my $choke = 0;

    for $tile (@$los) {
        next unless $tile->x * ( $dx - $dy) + $tile->y * ( $dx + $dy) > 0;
        next unless $tile->x * ( $dx + $dy) + $tile->y * (-$dx + $dy) > 0;

        if () { # useful chokepoint
            $choke = 1;
        }

        if ($tile->has_enemy) {
            return 0;
        }
    }

    return 0 unless $choke;

    my $to = TAEB->current_level->at_direction($dest);

    return 0 unless defined $to
               && $to->is_walkable
               && !$to->has_monster
               && $to->type ne 'trap';

    return 0 if (TAEB->current_tile->type eq 'opendoor'
            || $to->type eq 'opendoor')
           && $back =~ /[yubn]/;

    return 1;
}

sub prepare {
    my $self = shift;

    my @enemies = grep { $_->in_los } TAEB->current_level->has_enemies;

    # Useless in one-on-one fights
    return if @enemies <= 1;

    my $los = TAEB->los;

    my @dirs = grep { $self->useful_dir($los, [delta2vi $_]) }
        qw/h j k l y u b n/;

    if (@dirs) {
        $self->do(move => direction => $dirs[0]);
        $self->currently("Running for a chokepoint");
        $self->urgency('normal');
    }
}

sub urgencies {
    return {
        normal => "running for a chokepoint",
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;



# Kiting - speed system (ab)use by attacking while running away to prevent
#   counterattacks.  Currently we only handle projectile attacks against
#   single melee monsters, which suffices for the very important case of
#   nymphs and foocubi.

package TAEB::AI::Behavioral::Behavior::Kite;
use Moose;
use TAEB::OO;
use TAEB::Util 'delta2vi';
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my @enemies = grep { $_->in_los } TAEB->current_level->has_enemies;

    # For now, only handle one-on-one fights
    return unless @enemies == 1;

    my $enemy = $enemies[0];

    # and unless the enemy is next to us and kitable, act normally
    return unless abs($enemy->x - TAEB->x) <= 1
               && abs($enemy->y - TAEB->y) <= 1;

    return if !$enemy->can_be_outrun || TAEB::Action::Move->is_impossible;
    #return unless $enemy->should_attack_at_range;

    # Don't try to kite non-infravisible monsters in the dark.  TAEB
    # is too stupid to remember the kiting attempt, and will just explore
    # right back into said monster.
    return if !$enemy->tile->is_lit && !$enemy->can_be_infraseen;

    # do we have a projectile to throw?  No sense backing away otherwise (yet)
    return unless defined (TAEB->inventory->has_projectile)
               && !$enemy->tile->in_shop;

    # Until EkimFight is the default, all this does more harm than good,
    # because TAEB will just walk up to the monster
    #my @opt;
    #my $edir = delta2vi($enemy->x - TAEB->x, $enemy->y - TAEB->y);
    #my ($dirs) = "ykulnjbhykulnjb" =~ /$edir.(.....)/; #priceless

    #TAEB->each_adjacent(sub {
    #    my ($tile, $dir) = @_;

    #    return unless $tile->is_walkable;

    #    if ((TAEB->current_tile->type eq 'opendoor' ||
    #            $tile->type eq 'opendoor') && $dir =~ /[yubn]/) {
    #        return;
    #    }

    #    my $dist = (index $dirs, $dir) - 2;
    #    return unless defined $dist && ($dir =~ /[yubn]/ || abs($dist) < 2);

    #    $opt[abs($dist)] ||= $dir;
    #});

    #return unless defined (my $back = $opt[0] || $opt[1] || $opt[2]);

    my $back = delta2vi(TAEB->x - $enemy->x, TAEB->y - $enemy->y);
    my $to = TAEB->current_level->at_direction($back);

    return unless defined $to
               && $to->is_walkable
               && !$to->has_monster
               && $to->type ne 'trap';

    return if (TAEB->current_tile->type eq 'opendoor'
            || $to->type eq 'opendoor')
           && $back =~ /[yubn]/;


    $self->do(move => direction => $back);
    $self->currently("Kiting");
    $self->urgency('normal');
}

use constant max_urgency => 'normal';

__PACKAGE__->meta->make_immutable;

1;


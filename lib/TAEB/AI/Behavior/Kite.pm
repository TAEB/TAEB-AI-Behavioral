#!/usr/bin/env perl

# Kiting - speed system (ab)use by attacking while running away to prevent
#   counterattacks.  Currently we only handle projectile attacks against
#   single melee monsters, which suffices for the very important case of
#   nymphs and foocubi.

package TAEB::AI::Behavior::Kite;
use TAEB::OO;
use TAEB::Util 'delta2vi';
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    TAEB->debug("considering kite...");

    my @enemies = grep { $_->in_los } TAEB->current_level->has_enemies;

    TAEB->debug ((scalar @enemies) . " enemies visible...");
    # For now, only handle one-on-one fights
    return 0 unless @enemies == 1;

    my $enemy = $enemies[0];

    TAEB->debug($enemy->y . "," . $enemy->x . " " . TAEB->y . "," . TAEB->x);
    # and unless the enemy is next to us and kitable, act normally
    return 0 unless abs($enemy->x - TAEB->x) <= 1
                 && abs($enemy->y - TAEB->y) <= 1;

    TAEB->debug("and he's next to us...");
    return 0 unless $enemy->can_be_outrun;
    TAEB->debug("and we can outrun him...");
    #return 0 unless $enemy->melee_disposition == -1;

    # do we have a projectile to throw?  No sense backing away otherwise (yet)
    return 0 unless defined (TAEB->inventory->has_projectile);
    TAEB->debug("and we have projectiles...");

    my @opt;
    my $edir = delta2vi($enemy->x - TAEB->x, $enemy->y - TAEB->y);
    my ($dirs) = "ykulnjbhykulnjb" =~ /$edir.(.....)/; #priceless

    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;

        TAEB->debug("Looking " . $dir . "...");

        return unless $tile->is_walkable;

        if (TAEB->current_tile->type eq 'opendoor' && $dir =~ /[yubn]/) {
            TAEB->debug("but a door.");
            return;
        }

        TAEB->debug("It's walkable...");

        my $dist = (index $dirs, $dir) - 2;
        return unless defined $dist && ($dir =~ /[yubn]/ || abs($dist) < 2);

        TAEB->debug("And useful...");

        $opt[abs($dist)] ||= $dir;
    });

    return 0 unless defined (my $back = $opt[0] || $opt[1] || $opt[2]);

    TAEB->debug("We have a useful move! (" . $back . ")");

    $self->do(move =>
        direction   => $back,
    );
    $self->currently("Kiting.");
    TAEB->debug("and... " . $self->action);
    return 100;
}

sub urgencies {
    return {
        100 => "backing away from an outrunnable melee monster with intent to kite",
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


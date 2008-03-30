#!/usr/bin/env perl
package TAEB::World::Cartographer;
use TAEB::OO;

has dungeon => (
    isa      => 'TAEB::World::Dungeon',
    weak_ref => 1,
    required => 1,
);

has x => (
    isa => 'Int',
);

has y => (
    isa => 'Int',
);

sub update {
    my $self  = shift;
    $self->x(TAEB->vt->x);
    $self->y(TAEB->vt->y);

    if (TAEB->senses->is_engulfed) {
        return if $self->check_engulfed;
    }

    $self->check_dlvl;

    my $level = $self->dungeon->current_level;

    my $debug_draw = TAEB->config->debug_draw;
    my $needs_autoexplore = 0;

    for my $y (1 .. 21) {
        my $row = TAEB->vt->row_plaintext($y);
        my @colors = TAEB->vt->row_color($y);

        for my $x (0 .. 79) {
            my $tile = $level->at($x, $y);
            my $on_map = substr($row, $x, 1);

            $tile->try_monster($on_map, $colors[$x]);

            if ($on_map ne $tile->glyph || $colors[$x] != $tile->color) {
                $needs_autoexplore = 1;
                $level->update_tile($x, $y, $on_map, $colors[$x]);
            }

            TAEB->out("\e[%d;%dH%s\e[m", 1+$y, 1+$x, $tile->$debug_draw)
                if $debug_draw;
        }
    }

    TAEB->out("\e[%d;%dH", 1+$self->y, 1+$self->x) if $debug_draw;

    $level->step_on($self->x, $self->y);

    $self->autoexplore() if $needs_autoexplore;
}

=head2 map_like Regex -> Bool

Returns whether any part of the map (not the entire screen) matches Regex.

=cut

sub map_like {
    my $self = shift;
    my $re = shift;

    defined TAEB->vt->find_row(sub {
        my ($row, $y) = @_;
        $y > 0 && $y < 22 && $row =~ $re;
    });
}

=head2 check_dlvl

Updates the current_level if Dlvl appears to have changed.

=cut

sub check_dlvl {
    my $self = shift;

    # (Dlvl:\d+|Home \d+|Fort Ludios|End Game|Astral Plane)
    TAEB->vt->row_plaintext(23) =~ /^Dlvl:(\d+) /
        or do {
            TAEB->error("Unable to parse the botl for dlvl: ".TAEB->vt->row_plaintext(23));
            return;
    };

    my $dlvl = $1;
    my $level = $self->dungeon->current_level;

    if ($level->z != $dlvl) {
        TAEB->info("Oh! We seem to be on a different map. Was ".$level->z.", now $dlvl.");

        my $newlevel = $self->dungeon->get_level($dlvl);
        $self->dungeon->current_level($newlevel);
        TAEB->enqueue_message('dlvl_change', $level->z => $dlvl);
    }
}

=head2 autoexplore

Mark tiles that are obviously explored as such. Things like "a tile
with no unknown neighbors".

=cut

sub autoexplore {
    my $self = shift;

    for my $y (1 .. 21) {
        TILE: for my $x (0 .. 79) {
            my $tile = $self->dungeon->current_level->at($x, $y);

            if (!$tile->explored && $tile->type ne 'rock') {
                $tile->explored(1)
                    unless $tile->any_adjacent(sub { shift->type eq 'rock' });
            }

            # XXX: corridors need love
        }
    }
}

sub msg_dungeon_feature {
    my $self    = shift;
    my $feature = shift;
    my ($floor, $type);

    if ($feature eq 'staircase down') {
        $floor = '>';
        $type  = 'stairsdown';
    }
    elsif ($feature eq 'staircase up') {
        $floor = '<';
        $type  = 'stairsup';
    }
    elsif ($feature eq 'fountain' || $feature eq 'sink') {
        $floor = '{';
        $type  = $feature;
    }
    elsif ($feature eq 'fountain dries up') {
        $floor = '.';
        $type  = 'floor';
    }
    elsif ($feature eq 'trap') {
        my $traptype = shift;

        $floor = '^';
        $type  = 'trap';
    }
    elsif ($feature eq 'grave') {
        $floor = '\\';
        $type = 'grave';
    }
    else {
        # we don't know how to handle it :/
        return;
    }

    my $tile     = TAEB->current_tile;
    my $oldtype  = $tile->type;
    my $oldfloor = $tile->floor_glyph;

    if ($oldtype ne $type || $oldfloor ne $floor) {
        TAEB->debug("msg_dungeon_feature('$feature') caused the current tile to be updated from ('$oldfloor', '$oldtype') to ('$floor', '$type')");
    }

    $tile->change_type($type => $floor);
}

sub msg_clear_floor {
    my $self = shift;
    my $item = shift;

    TAEB->current_tile->clear_items;
}

sub msg_floor_item {
    my $self = shift;
    my $item = shift;

    TAEB->current_tile->add_item($item);
}

sub msg_remove_floor_item {
    my $self = shift;
    my $item = shift;

    for my $i (0 .. TAEB->current_tile->item_count - 1) {
        my $tile_item = TAEB->current_tile->items->[$i];

        if ($item->maybe_is($tile_item)) {
            TAEB->current_tile->remove_item($i);
            return;
        }
    }

    return if $item->is_autopickuped;

    TAEB->error("Unable to remove $item from the floor. Did we just pick it up or no?");
}

sub msg_floor_message {
    my $self = shift;
    my $message = shift;

    TAEB->debug(TAEB->current_tile . " is now engraved with \'$message\'");
    TAEB->current_tile->engraving($message);
}

sub msg_pickaxe {
    TAEB->current_level->pickaxe(TAEB->turn);
}

sub msg_debt {
    TAEB->current_tile->floodfill(
        sub {
            my $t = shift;
            $t->type eq 'floor' || $t->type eq 'obscured'
        },
        sub {
            my $t = shift;
            return if $t->in_shop;
            TAEB->debug("(" . $t->x . ", " . $t->y . ") is in a shop!");
            $t->in_shop(1);
        },
    );
}

sub msg_vault_guard {
    TAEB->current_tile->floodfill(
        sub {
            my $t = shift;
            $t->type eq 'floor' || $t->type eq 'obscured'
        },
        sub {
            my $t = shift;
            return if $t->in_vault;
            TAEB->debug("(" . $t->x . ", " . $t->y . ") is in a vault!");
            $t->in_vault(1);
        },
    );
}

=head2 check_engulfed -> Bool

Checks the screen to see if we're still engulfed. If so, returns 1. Otherwise,
returns 0 and tells the rest of the system that we're no longer engulfed.

=cut

my @engulf_expected = (
    [-1, -1] => '/',
    [ 0, -1] => '-',
    [ 1, -1] => '\\',
    [-1,  0] => '|',
    [ 1,  0] => '|',
    [-1,  1] => '\\',
    [ 0,  1] => '-',
    [ 1,  1] => '/',
);

sub check_engulfed {
    my $self = shift;

    for (my $i = 0; $i < @engulf_expected; $i += 2) {
        my ($deltas, $glyph) = @engulf_expected[$i, $i + 1];
        my ($dx, $dy) = @$deltas;

        my $got = TAEB->vt->at(TAEB->x + $dx, TAEB->y + $dy);
        next if $got eq $glyph;

        TAEB->info("We're no longer engulfed! I expected to see $glyph at delta ($dx, $dy) but I saw $got.");
        TAEB->enqueue_message(engulfed => 0);
        return 0;
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


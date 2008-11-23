#!/usr/bin/env perl
package TAEB::World::Cartographer;
use TAEB::OO;
use NetHack::FOV 'calculate_fov';

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

has fov => (
    isa       => 'ArrayRef',
    is        => 'ro',
    default   => sub { calculate_fov(TAEB->x, TAEB->y, sub {
            my $tile = TAEB->current_level->at(@_);
            $tile && $tile->is_transparent ? 1 : 0;
        }) },
    clearer   => 'invalidate_fov',
    lazy      => 1,
);

sub update {
    my $self  = shift;

    my ($old_x, $old_y) = ($self->x, $self->y);
    my $old_level = $self->dungeon->current_level;

    my ($Tx, $Ty) = (TAEB->vt->x, TAEB->vt->y);
    $self->x($Tx);
    $self->y($Ty);

    return if $self->is_engulfed;

    return unless $self->check_dlvl;

    my $level = $self->dungeon->current_level;

    my $tile_changed = 0;

    $level->iterate_tile_vt(sub {
        my ($tile, $glyph, $color, $x, $y) = @_;

        $tile->_clear_monster if $tile->has_monster;
        $tile->try_monster($glyph, $color)
            unless $Tx == $x && $Ty == $y;

        if ($glyph ne $tile->glyph || $color != $tile->color) {
            $tile_changed = 1;
            $level->update_tile($x, $y, $glyph, $color);
        }
        # XXX: this should be checking for 'visual range' (taking blindness and
        # lamps into account) - currently blindness is tested for in
        # Tile::update
	elsif (abs($x - $Tx) <= 1
            && abs($y - $Ty) <= 1
	    && $tile->type eq 'unexplored') {
	    $level->update_tile($x, $y, $glyph, $color);
	}

        return 1;
    });

    $old_level->step_off($old_x, $old_y) if defined($old_x);
    $level->step_on($self->x, $self->y);

    if ($tile_changed) {
        $self->autoexplore;
        $self->dungeon->current_level->detect_branch;
        TAEB->enqueue_message('tile_changes');
    }

    if ($tile_changed || $self->x != $old_x || $self->y != $old_y) {
        $self->invalidate_fov;
    }
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

    my $botl = TAEB->vt->row_plaintext(23);
    $botl =~ /^(Dlvl|Home|Fort Ludios|End Game|Astral Plane)(?:\:|\s)(\d*) /
        or do {
            TAEB->error("Unable to parse the botl for dlvl: $botl");
            return;
    };

    my $level = $self->dungeon->current_level;
    my $descriptor = $1;
    my $dlvl = $2 || $level->z;

    if ($level->z != $dlvl) {
        TAEB->info("Oh! We seem to be on a different map. Was ".$level->z.", now $dlvl.");

        my @levels = $self->dungeon->get_levels($dlvl);
        my $newlevel;

        for my $level (@levels) {
            if ($level->matches_vt) {
                $newlevel = $level;
                last;
            }
        }

        unless ($newlevel) {
            $newlevel = $self->dungeon->create_level($dlvl);
            if ($dlvl >= 2 && $dlvl <= 10) {
                if ($newlevel->detect_sokoban_vt) {
                    $newlevel->branch('sokoban');
                }
            }
            if ($dlvl >= 10 && $dlvl <= 12) {
                if ($newlevel->detect_bigroom_vt) {
                    $newlevel->branch('dungeons');
                    $newlevel->is_bigroom(1);
                }
            }
            if ($botl =~ /\*:\d+/) {
                $newlevel->branch('dungeons');
                $newlevel->is_rogue(1);
            }
            else { $newlevel->is_rogue(0) }
            if ($descriptor eq 'Home') {
                $newlevel->branch('quest');
            }
            elsif ($descriptor eq 'Fort Ludios') {
                $newlevel->branch('ludios');
            }
        }

        $self->dungeon->current_level($newlevel);
        TAEB->enqueue_message('dlvl_change', $level->z => $dlvl);
    }

    return 1;
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

            if (!$tile->explored
             && $tile->type ne 'rock'
             && $tile->type ne 'unexplored') {
                $tile->explored(1) unless $tile->any_adjacent(sub {
                    shift->type eq 'unexplored'
                });
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
    elsif ($feature eq 'bad staircase') {
	# Per Eidolos' idea: all stairs in rogue are marked as stairsdown, and
	# we only change them to stairs up if we get a bad staircase message.
	# This code was originally to fix mimics being stairs inside a shop,
	# but we don't have to worry about mimics in Rogue.
	if (!TAEB->current_level->is_rogue) {
	    $floor = ' ';
	    $type = 'obscured';
	} else {
	    $floor = '<';
	    $type = 'stairsup';
	}
    }
    elsif ($feature eq 'fountain' || $feature eq 'sink') {
        $floor = '{';
        $type  = $feature;
    }
    elsif ($feature eq 'fountain dries up' || $feature eq 'brokendoor') {
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
    elsif ($feature =~ /\baltar$/) {
        $floor = '_';
        $type = 'altar';
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

    TAEB->current_tile->add_item($item) if $item;
}

sub msg_remove_floor_item {
    my $self = shift;
    my $item = shift;
    my $tile = TAEB->current_tile;

    for my $i (0 .. $tile->item_count - 1) {
        my $tile_item = $tile->items->[$i];

        if ($item->maybe_is($tile_item)) {
            $tile->remove_item($i);
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

    my @doors = TAEB->current_tile->grep_adjacent(sub { $_->type eq 'closeddoor' });
    if (@doors) {
        if (TAEB::Spoilers::Engravings->is_degradation("Closed for inventory" => $message)) {
            $_->is_shop(1) for @doors;
        }
    }
}

sub msg_engraving_type {
    my $self = shift;
    my $engraving_type = shift;

    TAEB->current_tile->engraving_type($engraving_type);
}

sub msg_pickaxe {
    TAEB->current_level->pickaxe(TAEB->turn);
}

sub floodfill_room {
    my $self = shift;
    my $type = shift;
    my $tile = shift || TAEB->current_tile;
    $tile->floodfill(
        sub {
            my $t = shift;
            $t->type eq 'floor' || $t->type eq 'obscured' || $t->type eq 'altar'
        },
        sub {
            my $t   = shift;
            my $var = "in_$type";
            return if $t->$var;
            TAEB->debug("$t is in a $type!");
            $t->$var(1);
        },
    );
}

sub msg_debt {
    shift->floodfill_room('shop');
}

sub msg_enter_room {
    my $self     = shift;
    my $type     = shift || return;
    my $subtype  = shift;
    # Okay, so we want to floodfill the room when we enter it.
    # Because we get the message in the doorway, we can't floodfill from that
    # tile, so therefore we will use the target tile which (presumably?) is
    # inside the room.
    return unless TAEB->has_action
               && TAEB->action->can('path')
               && TAEB->action->path
               && TAEB->action->path->to;

    $self->floodfill_room($type,TAEB->action->path->to);
}

sub msg_vault_guard {
    shift->floodfill_room('vault');
}

=head2 is_engulfed -> Bool

Checks the screen to see if we're engulfed. It'll inform the rest of the system
about our engulfedness. Returns 1 if we're engulfed, 0 if not.

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

sub is_engulfed {
    my $self = shift;

    for (my $i = 0; $i < @engulf_expected; $i += 2) {
        my ($deltas, $glyph) = @engulf_expected[$i, $i + 1];
        my ($dx, $dy) = @$deltas;

        my $got = TAEB->vt->at(TAEB->x + $dx, TAEB->y + $dy);
        next if $got eq $glyph;

        return 0 unless TAEB->is_engulfed;

        TAEB->info("We're no longer engulfed! I expected to see $glyph at delta ($dx, $dy) but I saw $got.");
        TAEB->enqueue_message(engulfed => 0);
        return 0;
    }

    TAEB->info("We're engulfed!");
    TAEB->enqueue_message(engulfed => 1);
    return 1;
}

sub msg_branch {
    my $self   = shift;
    my $branch = shift;
    my $level  = $self->dungeon->current_level;

    $level->branch($branch)
        unless $level->known_branch;

    return if $level->branch eq $branch;

    TAEB->error("Tried to set the branch of $level to $branch but it already has a branch.");
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


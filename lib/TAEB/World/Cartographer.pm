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

    $self->check_dlvl;

    my $level = $self->dungeon->current_level;

    my $debug_draw = TAEB->config->debug_draw;
    my $needs_autoexplore = 0;

    for my $y (1 .. 21) {
        for my $x (0 .. 79) {
            my $tile = $level->at($x, $y);
            if (TAEB->vt->at($x, $y) ne $tile->glyph) {
                $needs_autoexplore = 1;
                $level->update_tile($x, $y, TAEB->vt->at($x, $y),
                                    TAEB->vt->color($x, $y));
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
        or TAEB->error("Unable to parse the botl for dlvl: ".TAEB->vt->row_plaintext(23));

    my $dlvl = $1;
    my $level = $self->dungeon->current_level;

    if ($level->z != $dlvl) {
        TAEB->info("Oh! We seem to be on a different map. Was ".$level->z.", now $dlvl.");

        my $branch = $self->dungeon->branches->{dungeons};
        $self->dungeon->current_level($branch->levels->[$dlvl] ||= TAEB::World::Level->new(branch => $branch, z => $dlvl));

        TAEB->enqueue_message('dlvl_change', $level->z => $dlvl);
    }
}

=head2 autoexplore

Mark tiles that are obviously explored as such. Things like "a tile
with no unknown neighbors".

=cut

sub autoexplore {
    my $self = shift;

    # "Exiting subroutine via next". Yes, Perl. I know this.
    no warnings 'exiting';

    for my $y (1 .. 21) {
        TILE: for my $x (0 .. 79) {
            my $tile = $self->dungeon->current_level->at($x, $y);

            if (!$tile->explored && $tile->type ne 'rock') {
                $tile->each_adjacent(sub {
                    next TILE if shift->type eq 'rock'
                });

                $tile->explored(1);
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
        $type  = 'stairs';
    }
    elsif ($feature eq 'staircase up') {
        $floor = '<';
        $type  = 'stairs';
    }
    elsif ($feature eq 'fountain dries up') {
        $floor = '.';
        $type  = 'floor';
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

    # XXX: this doesn't handle upgrading Tile to Tile::Stairs
    $tile->type($type);
    $tile->floor_glyph($floor);
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

sub msg_got_item {
    my $self = shift;
    my $item = shift;

    # remove slot
    (my $raw = $item->raw) =~ s/^. - //;

    for my $i (0 .. TAEB->current_tile->item_count - 1) {
        (my $item = TAEB->current_tile->items->[$i]->raw) =~ s/^. - //;
        if ($raw eq $item) {
            TAEB->current_tile->remove_item($i);
            return;
        }
    }

    TAEB->error("Unable to remove $item from the floor. Did we just pick it up or no?");
}

make_immutable;
no Moose;

1;


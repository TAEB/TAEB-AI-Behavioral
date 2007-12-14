#!/usr/bin/env perl
package TAEB::World::Cartographer;
use Moose;

has dungeon => (
    is       => 'rw',
    isa      => 'TAEB::World::Dungeon',
    weak_ref => 1,
    required => 1,
);

has x => (
    is => 'rw',
    isa => 'Int',
);

has y => (
    is => 'rw',
    isa => 'Int',
);

sub update {
    my $self  = shift;
    my $level = $self->dungeon->current_level;

    $self->check_dlvl;

    my $debug_draw = $main::taeb->config->contents->{debug_draw};

    for my $y (1 .. 21) {
        for my $x (0 .. 79) {
            my $tile = $level->at($x, $y);
            if ($main::taeb->vt->at($x, $y) ne $tile->glyph) {
                $level->update_tile($x, $y, $main::taeb->vt->at($x, $y));
            }

            $main::taeb->out("\e[%d;%dH%s\e[m", 1+$y, 1+$x, $tile->$debug_draw)
                if $debug_draw;
        }
    }

    # XXX: ugh. this needs to be smarter.
    $self->x($main::taeb->vt->x);
    $self->y($main::taeb->vt->y);
    $main::taeb->out("\e[%d;%dH", 1+$self->y, 1+$self->x) if $debug_draw;

    $level->step_on($self->x, $self->y);

    $self->autoexplore();
}

sub current_tile {
    my $self = shift;
    $self->dungeon->current_level->at($self->x, $self->y);
}

=head2 map_like Regex -> Bool

Returns whether any part of the map (not the entire screen) matches Regex.

=cut

sub map_like {
    my $self = shift;
    my $re = shift;

    defined $main::taeb->vt->find_row(sub {
        my ($row, $y) = @_;
        $y > 0 && $y < 22 && $row =~ $re;
    });
}

=head2 check_dlvl

Updates the current_level if Dlvl appears to have changed.

=cut

sub check_dlvl {
    my $self = shift;

    $main::taeb->vt->row_plaintext(23) =~ /^Dlvl:(\d+) /
        or $main::taeb->error("Unable to parse the botl for dlvl: ".$main::taeb->vt->row_plaintext(23));

    my $dlvl = $1;
    my $level = $self->dungeon->current_level;

    if ($level->z != $dlvl) {
        $main::taeb->info("Oh! We seem to be on a different map. Was ".$level->z.", now $dlvl.");

        my $branch = $self->dungeon->branches->{dungeons};
        $self->dungeon->current_level($branch->levels->[$dlvl] ||= TAEB::World::Level->new(branch => $branch, z => $dlvl));
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

            if (!$tile->explored && $tile->glyph ne ' ') {
                $tile->each_other_neighbor(sub {
                    next TILE if shift->glyph eq ' '
                });

                $tile->explored(1);
            }

            # XXX: corridors need love
        }
    }

}

1;


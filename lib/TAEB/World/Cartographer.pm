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
    # XXX: ugh. this needs to be smarter.
    $self->x(TAEB->vt->x);
    $self->y(TAEB->vt->y);

    $self->check_dlvl;

    my $level = $self->dungeon->current_level;

    my $debug_draw = TAEB->config->contents->{debug_draw};
    my $needs_autoexplore = 0;

    for my $y (1 .. 21) {
        for my $x (0 .. 79) {
            my $tile = $level->at($x, $y);
            if (TAEB->vt->at($x, $y) ne $tile->glyph) {
                $needs_autoexplore = 1;
                $level->update_tile($x, $y, TAEB->vt->at($x, $y));
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

    TAEB->vt->row_plaintext(23) =~ /^Dlvl:(\d+) /
        or TAEB->error("Unable to parse the botl for dlvl: ".TAEB->vt->row_plaintext(23));

    my $dlvl = $1;
    my $level = $self->dungeon->current_level;

    if ($level->z != $dlvl) {
        TAEB->info("Oh! We seem to be on a different map. Was ".$level->z.", now $dlvl.");

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

            if (!$tile->explored && $tile->type ne 'rock') {
                $tile->each_other_neighbor(sub {
                    next TILE if shift->type eq 'rock'
                });

                $tile->explored(1);
            }

            # XXX: corridors need love
        }
    }

}

1;


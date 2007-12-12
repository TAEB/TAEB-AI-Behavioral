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
    for my $y (1 .. 21) {
        for my $x (0 .. 79) {
            if ($main::taeb->vt->at($x, $y) ne $level->at($x, $y)->glyph) {
                $level->update_tile($x, $y, $main::taeb->vt->at($x, $y));
            }
        }
    }

    # XXX: ugh. this needs to be smarter.
    $self->x($main::taeb->vt->x);
    $self->y($main::taeb->vt->y);

    $level->step_on($self->x, $self->y);
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

    if ($level->z != $dlvl) {
        $main::taeb->info("Oh! We seem to be on a different map. Was ".$level->z.", now $dlvl.");
        $self->dungeon->current_level($self->dungeon->branches->{dungeons}->levels->[$dlvl]);
    }
}

1;


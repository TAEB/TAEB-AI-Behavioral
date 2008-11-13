#!/usr/bin/env perl
package TAEB::Display;
use TAEB::OO;
use Curses ();
use TAEB::Util ':colors';

has color_method => (
    isa     => 'Str',
    clearer => 'reset_color_method',
    lazy    => 1,
    default => sub { TAEB->config->color_method || 'normal' },
);

has glyph_method => (
    isa     => 'Str',
    clearer => 'reset_glyph_method',
    lazy    => 1,
    default => sub { TAEB->config->glyph_method || 'normal' },
);

sub pathfinding { shift->color_method eq 'pathfind' }

sub _notify {
    my $self  = shift;
    my $msg   = shift;
    my $color = shift;
    my $sleep = @_ ? shift : 3;

    return if !defined($msg) || !length($msg);

    # strip off extra lines, it's too distracting
    $msg =~ s/\n.*//s;

    Curses::move(1, 0);
    Curses::attron(Curses::COLOR_PAIR($color));
    Curses::addstr($msg);
    Curses::attroff(Curses::COLOR_PAIR($color));
    Curses::clrtoeol;

    # using TAEB->x and TAEB->y here could screw up horrifically if the dungeon
    # object isn't loaded yet, and loading it calls notify..
    $self->place_cursor(TAEB->vt->x, TAEB->vt->y);

    return if $sleep == 0;

    sleep $sleep;
    $self->redraw;
}

sub redraw {
    my $self = shift;
    my %args = @_;

    if ($args{force_clear}) {
        Curses::clear;
        Curses::refresh;
    }

    my $level  = $args{level} || TAEB->current_level;
    my $color_method = $self->color_method . '_color';
    my $glyph_method = $self->glyph_method . '_glyph';

    for my $y (1 .. 21) {
        Curses::move($y, 0);
        for my $x (0 .. 79) {
            my $tile = $level->at($x, $y);
            my $color = $tile->$color_method;
            my $glyph = $tile->$glyph_method;

            Curses::addch($color | ord($glyph));
        }
    }

    $self->draw_botl($args{botl}, $args{status});
    $self->place_cursor;
}

sub draw_botl {
    my $self   = shift;
    my $botl   = shift;
    my $status = shift;

    return unless TAEB->state eq 'playing';

    Curses::move(22, 0);

    if (!$botl) {
        my $command = TAEB->has_action ? TAEB->action->command : '?';
        $command =~ s/\n/\\n/g;
        $command =~ s/\e/\\e/g;
        $command =~ s/\cd/^D/g;

        $botl = TAEB->checking
              ? "Checking " . TAEB->checking
              : TAEB->currently . " ($command)";
    }

    Curses::addstr($botl);

    Curses::clrtoeol;
    Curses::move(23, 0);

    if (!$status) {
        my @pieces;
        push @pieces, 'D:' . TAEB->current_level->z;
        $pieces[-1] .= uc substr(TAEB->current_level->branch, 0, 1)
            if TAEB->current_level->known_branch;
        $pieces[-1] .= ' ('. ucfirst(TAEB->current_level->special_level) .')'
            if TAEB->current_level->special_level;

        push @pieces, 'H:' . TAEB->hp;
        $pieces[-1] .= '/' . TAEB->maxhp
            if TAEB->hp != TAEB->maxhp;

        if (TAEB->spells->has_spells) {
            push @pieces, 'P:' . TAEB->power;
            $pieces[-1] .= '/' . TAEB->maxpower
                if TAEB->power != TAEB->maxpower;
        }

        push @pieces, 'A:' . TAEB->ac;
        push @pieces, 'X:' . TAEB->level;
        push @pieces, 'N:' . TAEB->nutrition;
        push @pieces, 'T:' . TAEB->turn;
        push @pieces, 'S:' . TAEB->score
            if TAEB->has_score;
        push @pieces, '$' . TAEB->gold;
        push @pieces, 'P:' . TAEB->pathfinds;

        my $statuses = join '', map { ucfirst substr $_, 0, 2 } TAEB->statuses;
        push @pieces, '[' . $statuses . ']'
            if $statuses;

        $status = join ' ', @pieces;
    }

    Curses::addstr($status);
    Curses::clrtoeol;
}

sub place_cursor {
    my $self = shift;
    my $x    = shift || TAEB->x;
    my $y    = shift || TAEB->y;

    Curses::move($y, $x);
    Curses::refresh;
}

sub display_topline {
    my $self = shift;
    my @messages = TAEB->parsed_messages;

    if (@messages == 0) {
        # we don't need to worry about the other rows, the map will
        # overwrite them
        Curses::move 0, 0;
        Curses::clrtoeol;
        $self->place_cursor;
        return;
    }

    while (my @msgs = splice @messages, 0, 20) {
        my $y = 0;
        for (@msgs) {
            my ($line, $matched) = @$_;

            if (TAEB->config->spicy
            &&  TAEB->config->spicy ne 'hold back on the chili, please') {
                my @spice = (
                    'rope golem',                'rape golem',             0.2,
                    'oil lamp',                  'Garin',                  0.5,
                    '\bhit',                     'roundhouse-kick',        0.02,
                    'snoring snakes',            'Eidolos taking a nap',   1,
                    'hear a strange wind',   'smell Eidolos passing wind', 1,
                    qr/(?:jackal|wolf) howling/, 'Eidolos howling',        1,
                );

                while (my ($orig, $sub, $prob) = splice @spice, 0, 3) {
                    $line =~ s/$orig/$sub/ if rand() < $prob;
                }
            }

            my $chopped = length($line) > 75;
            $line = substr($line, 0, 75);

            Curses::move $y++, 0;

            my $color = $matched
                      ? Curses::COLOR_PAIR(COLOR_GREEN)
                      : Curses::COLOR_PAIR(COLOR_BROWN);

            Curses::attron($color);
            Curses::addstr($line);
            Curses::attroff($color);

            Curses::addstr '...' if $chopped;

            Curses::clrtoeol;
        }

        if (@msgs > 1) {
            $self->place_cursor;
            #sleep 1;
            #sleep 2 if @msgs > 5;
            TAEB->redraw if @messages;
        }
    }
    $self->place_cursor;
}

=head2 change_draw_mode

This is a debug command. It's expected to read another character from the
keyboard deciding how to change the draw mode.

Eventually we may want a menu interface but this is fine for now.

=cut

my %mode_changes = (
    0 => {
        summary => 'Displays normal NetHack colors',
        execute => sub { shift->color_method('normal') },
    },
    d => {
        summary => 'Sets debug coloring',
        execute => sub { shift->color_method('debug') },
    },
    p => {
        summary => 'Sets pathfind display',
        execute => sub { shift->color_method('pathfind') },
    },
    s => {
        summary => 'Sets stepped-on coloring',
        execute => sub { shift->color_method('stepped') },
    },
    l => {
        summary => 'Displays lit tiles',
        execute => sub { shift->color_method('lit') },
    },
    f => {
        summary => 'Draws floor glyphs',
        execute => sub { shift->glyph_method('floor') },
    },
    n => {
        summary => 'Resets color and floor draw modes',
        execute => sub {
            my $self = shift;
            $self->reset_color_method;
            $self->reset_glyph_method;
        },
    },
);

sub change_draw_mode {
    my $self = shift;

    my $mode = TAEB->get_key;
    return if $mode eq "\e";

    if (exists $mode_changes{$mode}) {
        $mode_changes{$mode}->{execute}->($self);
    }
    else {
        TAEB->complain("Invalid draw mode '$mode'");
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


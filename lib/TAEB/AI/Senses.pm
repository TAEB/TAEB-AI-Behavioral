#!/usr/bin/env perl
package TAEB::AI::Senses;
use TAEB::OO;

has role => (
    isa => 'Role',
);

has race => (
    isa => 'Race',
);

has align => (
    isa => 'Align',
);

has gender => (
    isa => 'Gender',
);

has hp => (
    isa => 'Int',
);

has maxhp => (
    isa => 'Int',
);

has power => (
    isa => 'Int',
);

has maxpower => (
    isa => 'Int',
);

has nutrition => (
    isa     => 'Int',
    default => 700,
);

has in_wereform => (
    isa => 'Bool',
);

has [qw/is_blind is_stunned is_confused is_hallucinating is_lycanthropic/] => (
    isa     => 'Bool',
    default => 0,
);

has level => (
    isa     => 'Int',
    default => 1,
);

has prev_turn => (
    isa     => 'Int',
    default => 0,
);

has turn => (
    isa     => 'Int',
    default => 0,
);

has max_god_anger => (
    isa     => 'Int',
    default => 0,
);

has in_beartrap => (
    isa     => 'Bool',
    default => 0,
);

has str => (
    isa     => 'Str',
    default => 0,
);

has [qw/dex con int wis cha/] => (
    isa     => 'Int',
    default => 0,
);

has score => (
    isa     => 'Int',
    default => 0,
);

sub parse_botl {
    my $self = shift;
    my $status = TAEB->vt->row_plaintext(22);
    my $botl   = TAEB->vt->row_plaintext(23);

    if ($status =~ /^(\w+)?.*?St:(\d+(?:\/(?:\*\*|\d+))?) Dx:(\d+) Co:(\d+) In:(\d+) Wi:(\d+) Ch:(\d+)\s*(\w+)\s*(.*)$/) {
        # $1 name
        $self->str($2);
        $self->dex($3);
        $self->con($4);
        $self->int($5);
        $self->wis($6);
        $self->cha($7);
        # $8 alignment

        # we can't assume that TAEB will always have showscore. for example,
        # slackwell.com (where he's playing as of this writing) doesn't have
        # that compiled in
        if ($9 =~ /S:(\d+)\s*/) {
            $self->score($1);
        }
    }
    else {
        TAEB->error("Unable to parse the status line '$status'");
    }

    if ($botl =~ /^(Dlvl:\d+|Home \d+|Fort Ludios|End Game|Astral Plane)\s+(?:\$|\*):(\d+)\s+HP:(\d+)\((\d+)\)\s+Pw:(\d+)\((\d+)\)\s+AC:([0-9-]+)\s+(?:Exp|Xp|HD):(\d+)(?:\/(\d+))?(?:\s+T:(\d+))?\s+(.*?)\s*$/) {
        # $1 dlvl (cartographer does this)
        # $2 gold
        $self->hp($3);
        $self->maxhp($4);
        $self->power($5);
        $self->maxpower($6);
        # $7 AC
        $self->level($8);
        # $9 experience
        $self->turn($10);
        # $self->status(join(' ', split(/\s+/, $11)));
    }
    else {
        TAEB->error("Unable to parse the botl line '$botl'");
    }
}

sub find_statuses {
    my $self = shift;
    my $status = TAEB->vt->row_plaintext(22);
    my $botl   = TAEB->vt->row_plaintext(23);

    if ($status =~ /^\S+ the Were/) {
        $self->in_wereform(1);
        $self->is_lycanthropic(1);
    }
    else {
        $self->in_wereform(0);
    }

    # we can definitely know some things about our nutrition
    if ($botl =~ /\bSat/) {
        $self->nutrition(1000) if $self->nutrition < 1000;
    }
    elsif ($botl =~ /\bHun/) {
        $self->nutrition(149)  if $self->nutrition > 149;
    }
    elsif ($botl =~ /\bWea/) {
        $self->nutrition(49)   if $self->nutrition > 49;
    }
    elsif ($botl =~ /\bFai/) {
        $self->nutrition(-1)   if $self->nutrition > -1;
    }
    else {
        $self->nutrition(999) if $self->nutrition > 999;
        $self->nutrition(150) if $self->nutrition < 150;
    }

    $self->is_blind($botl =~ /\bBli/);
    $self->is_stunned($botl =~ /\bStun/);
    $self->is_confused($botl =~ /\bConf/);
    $self->is_hallucinating($botl =~ /\bHal/);
}

sub update {
    my $self = shift;

    $self->parse_botl;
    $self->find_statuses;

    if ($self->prev_turn) {
        if ($self->turn != $self->prev_turn) {
            for ($self->prev_turn + 1 .. $self->turn) {
                TAEB->enqueue_message(turn => $_);
            }
        }
    }

    $self->prev_turn($self->turn);
}

sub msg_god_angry {
    my $self      = shift;
    my $max_anger = shift;

    $self->max_god_anger($max_anger);
}

sub can_pray {
    my $self = shift;
    return $self->max_god_anger == 0;
}

sub can_elbereth {
    my $self = shift;
    return not $self->in_wereform
            || $self->is_blind;
}

sub can_kick {
    my $self = shift;
    return not $self->in_beartrap;
}

sub msg_beartrap {
    my $self = shift;
    $self->in_beartrap(1);
}

sub msg_walked {
    my $self = shift;
    $self->in_beartrap(0);
}

sub msg_turn {
    my $self = shift;
    $self->nutrition($self->nutrition - 1);
}

sub msg_status_change {
    my $self     = shift;
    my $status   = shift;
    my $now_have = shift;

    if ($status eq 'lycanthropy') {
        $self->is_lycanthropic($now_have);
    }
}

sub elbereth_count {
    TAEB->write(":");
    TAEB->process_input;
    TAEB->current_tile->elbereths;
}

make_immutable;
no Moose;

1;


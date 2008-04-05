#!/usr/bin/env perl
package TAEB::Senses;
use TAEB::OO;

has name => (
    isa => 'Str',
);

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
    default => 900,
);

has in_wereform => (
    isa => 'Bool',
);

has [qw/is_blind is_stunned is_confused is_hallucinating is_lycanthropic is_engulfed is_grabbed/] => (
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

has step => (
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

has in_pit => (
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

has gold => (
    isa     => 'Int',
    default => 0,
);

has debt => (
    isa     => 'Maybe[Int]',
    default => 0,
);

has [
    qw/poison_resistant cold_resistant fire_resistant shock_resistant/
] => (
    isa     => 'Bool',
    default => 0,
);

has following_vault_guard => (
    isa     => 'Bool',
    default => 0,
);

has checking => (
    isa     => 'Str',
    clearer => 'clear_checking',
);

has last_prayed => (
    isa     => 'Int',
    default => -400,
);

has autopickup => (
    isa     => 'Bool',
    default => 1,
);

has ac => (
    isa     => 'Int',
    default => 10,
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

    if ($botl =~ /^(Dlvl:\d+|Home \d+|Fort Ludios|End Game|Astral Plane)\s+(?:\$|\*):(\d+)\s+HP:(\d+)\((\d+)\)\s+Pw:(\d+)\((\d+)\)\s+AC:([0-9-]+)\s+(?:Exp|Xp|HD):(\d+)(?:\/(\d+))?\s+T:(\d+)\s+(.*?)\s*$/) {
        # $1 dlvl (cartographer does this)
        $self->gold($2);
        $self->hp($3);
        $self->maxhp($4);
        $self->power($5);
        $self->maxpower($6);
        $self->ac($7);
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

    $self->is_blind($botl =~ /\bBli/ ? 1 : 0);
    $self->is_stunned($botl =~ /\bStun/ ? 1 : 0);
    $self->is_confused($botl =~ /\bConf/ ? 1 : 0);
    $self->is_hallucinating($botl =~ /\bHal/ ? 1 : 0);
}

sub update {
    my $self = shift;
    my $main = shift;

    if ($main) {
        $self->step($self->step + 1);
        TAEB->enqueue_message(step => $self->step);
    }

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

sub msg_autopickup {
    my $self    = shift;
    my $enabled = shift;
    $self->autopickup($enabled);
}

sub is_polymorphed {
    my $self = shift;
    return $self->in_wereform;
}

sub is_checking {
    my $self = shift;
    my $what = shift;
    return 0 unless defined($self->checking);
    return $self->checking eq $what;
}

sub msg_god_angry {
    my $self      = shift;
    my $max_anger = shift;

    $self->max_god_anger($max_anger);
}

sub can_pray {
    my $self = shift;
    return $self->max_god_anger == 0
        && TAEB->turn > $self->last_prayed + 500
}

sub can_engrave {
    my $self = shift;
    return not $self->in_wereform
            || $self->is_blind
            || $self->is_engulfed
            || TAEB->current_tile->type eq 'fountain'
            || TAEB->current_tile->type eq 'altar'
            || TAEB->current_tile->type eq 'grave';
}

sub can_open {
    my $self = shift;
    return not $self->in_wereform
            || $self->in_pit;
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
    $self->in_pit(0);
    if (!$self->autopickup xor TAEB->current_tile->in_shop) {
        TAEB->info("Toggling autopickup because we entered/exited a shop");
        TAEB->write("@");
        TAEB->process_input;
    }
}

sub msg_turn {
    my $self = shift;
    $self->nutrition($self->nutrition - 1);
}

my %method_of = (
    lycanthropy   => 'is_lycanthropic',
    blindness     => 'is_blind',
    confusion     => 'is_confused',
    stunning      => 'is_stunned',
    hallucination => 'is_hallucinating',
    engulfed      => 'is_engulfed',
    grabbed       => 'is_grabbed',
    pit           => 'in_pit',
);

sub msg_status_change {
    my $self     = shift;
    my $status   = shift;
    my $now_have = shift;

    if (my $method = $method_of{$status}) {
        $self->$method($now_have);
    }
}

sub msg_pit {
    my $self = shift;
    $self->msg_status_change(pit => @_);
}

sub msg_engulfed {
    my $self = shift;
    $self->msg_status_change(engulfed => @_);
}

sub msg_grabbed {
    my $self = shift;
    $self->msg_status_change(grabbed => @_);
}

sub elbereth_count {
    TAEB->write(":");
    TAEB->full_input;
    my $tile = TAEB->current_tile;
    my $elbereths = $tile->elbereths;
    TAEB->info("Tile (".$tile->x.", ".$tile->y.") has $elbereths Elbereths (".
                $tile->engraving.")");
    return $elbereths;
}

sub msg_nutrition {
    my $self = shift;
    my $nutrition = shift;

    $self->nutrition($nutrition);
}

# this is what NetHack uses to convert 18/whackiness to an integer
# or so I think. crosscheck src/attrib.c and src/botl.c..
sub numeric_strength {
    my $self = shift;
    my $str = $self->str;

    if ($str =~ /^(\d+)(?:\/(\*\*|\d+))?$/) {
        my $base = $1;
        my $ext  = $2 || 0;
        $ext = 100 if $ext eq '**' || $base <= 21;

        return $base if $base <= 18;
        return $base + int($ext / 2) if $base <= 21;
        return $base;
    }
    else {
        TAEB->error("Unable to parse strength $str.");
    }
}

sub msg_debt {
    my $self = shift;
    my $gold = shift;

    # gold is occasionally undefined. that's okay, that tells us to check
    # how much we owe with the $ command
    $self->debt($gold);
    if (!defined($gold)) {
        TAEB->enqueue_message(check => 'debt');
    }
}

sub msg_game_started {
    my $self = shift;

    $self->cold_resistant(1) if $self->role eq 'Val';

    $self->poison_resistant(1) if $self->role eq 'Hea'
                               || $self->role eq 'Bar'
                               || $self->race eq 'Orc';
}

sub msg_vault_guard {
    my $self = shift;
    my $following = shift;

    $self->following_vault_guard($following);
}

sub msg_check {
    my $self = shift;
    my $thing = shift;

    $self->checking($thing || "everything");
    if (!$thing) {
        # discoveries must come before inventory, otherwise I'd meta this crap
        $self->_check_crga;
        $self->_check_spells;
        $self->_check_discoveries;
        $self->_check_inventory;
        $self->_check_enhance;
        $self->_check_floor;
        $self->_check_debt;
        $self->_check_autopickup;
    }
    elsif (my $method = $self->can("_check_$thing")) {
        $self->$method;
    }
    else {
        $self->warning("I don't know how to check $thing.");
    }
    $self->clear_checking;
}

my %check_command = (
    discoveries => "\\",
    inventory   => "Da\n",
    spells      => "Z",
    crga        => "\cx",
    floor       => ":",
    debt        => '$',
    enhance     => "#enhance\n",
    autopickup  => "@@",
);

my %post_check = (
    debt => sub {
        my $self = shift;
        $self->debt(0) if !defined($self->debt);
    },
);

for my $check (keys %check_command) {
    my $command = $check_command{$check};
    my $post    = $post_check{$check};

    __PACKAGE__->meta->add_method("_check_$check" => sub {
        my $self = shift;
        TAEB->remove_messages(check => $check);
        TAEB->write($command);
        TAEB->full_input;
        $post->($self) if $post;
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


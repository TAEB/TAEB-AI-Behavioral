#!/usr/bin/env perl
package TAEB::Senses;
use TAEB::OO;

has name => (
    isa => 'Str',
);

has role => (
    isa => 'TAEB::Type::Role',
);

has race => (
    isa => 'TAEB::Type::Race',
);

has align => (
    isa => 'TAEB::Type::Align',
);

has gender => (
    isa => 'TAEB::Type::Gender',
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

has [qw/is_blind is_stunned is_confused is_hallucinating is_lycanthropic is_engulfed is_grabbed is_petrifying/] => (
    isa     => 'Bool',
    default => 0,
);

has [qw/is_fast is_very_fast/] => (
    traits  => ['TAEB::GoodStatus'],
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
    metaclass => 'Counter',
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

has in_web => (
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
    isa       => 'Int',
    predicate => 'has_score',
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

has last_seen_nurse => (
    isa => 'Int',
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

has dead => (
    isa     => 'Bool',
    default => 0,
);

has burden => (
    isa => 'TAEB::Type::Burden',
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
        # $8 align

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

    if ($botl =~ /\bOverl/) {
        $self->burden('Overloaded');
    }
    elsif ($botl =~ /\bOvert/) {
        $self->burden('Overtaxed');
    }
    elsif ($botl =~ /\bStra/) {
        $self->burden('Strained');
    }
    elsif ($botl =~ /\bStre/) {
        $self->burden('Stressed');
    }
    elsif ($botl =~ /\bBur/) {
        $self->burden('Burdened');
    }
    else {
        $self->burden('Unencumbered');
    }

    $self->is_blind($botl =~ /\bBli/ ? 1 : 0);
    $self->is_stunned($botl =~ /\bStun/ ? 1 : 0);
    $self->is_confused($botl =~ /\bConf/ ? 1 : 0);
    $self->is_hallucinating($botl =~ /\bHal/ ? 1 : 0);
}

sub statuses {
    my $self = shift;
    my @statuses;
    my @attr = grep { $_->name =~ /^is_/ }
               grep { !$_->does('TAEB::GoodStatus') }
               $self->meta->compute_all_applicable_attributes;

    for my $attr (@attr) {
        next unless $attr->get_value($self);
        my ($status) = $attr->name =~ /^is_(\w+)$/;
        push @statuses, $status;
    }
    return @statuses;
}

sub update {
    my $self = shift;
    my $main = shift;

    if ($main) {
        $self->inc_step;
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
            || $self->is_confused
            || $self->is_stunned
            || $self->is_hallucinating
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
    return not $self->in_beartrap
            || $self->in_pit
            || $self->in_web;
}

sub can_move {
    my $self = shift;
    return not $self->in_beartrap
            || $self->in_pit
            || $self->in_web
            || $self->is_grabbed
            || $self->is_engulfed;
}

sub msg_beartrap {
    my $self = shift;
    $self->in_beartrap(1);
    TAEB->enqueue_message('dungeon_feature' => 'trap' => 'beartrap');
}

sub msg_walked {
    my $self = shift;
    $self->in_beartrap(0);
    $self->in_pit(0);
    $self->in_web(0);
    $self->is_grabbed(0);
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
    pit           => 'in_pit',
    web           => 'in_web',
    stoning       => 'is_petrifying',
);

sub msg_status_change {
    my $self     = shift;
    my $status   = shift;
    my $now_have = shift;

    my $method = $method_of{$status} || "is_$status";

    if ($self->can($method)) {
        $self->$method($now_have);
    }
}

sub msg_pit {
    my $self = shift;
    $self->msg_status_change(pit => @_);
    TAEB->enqueue_message('dungeon_feature' => 'trap' => 'pit');
}

sub msg_web {
    my $self = shift;
    $self->msg_status_change(web => @_);
    TAEB->enqueue_message('dungeon_feature' => 'trap' => 'web');
}

sub msg_life_saving {
    my $self   = shift;
    my $target = shift;
    TAEB->debug("Life saving target: $target");
    #note that naming a monster "Your" returns "Your's" as the target
    if ($target eq 'Your') {
        #At least I had it on!
        #Remove it from inventory
        my $item = TAEB->inventory->amulet;
        TAEB->debug("Removing $item  from slot " . $item->slot . " beacuse it is life saving and we just used it.");
        TAEB->inventory->decrease_quantity($item->slot);
    }

    # oh well, i guess it wasn't my "oLS
    # trigger a discoveries check if we didn't know the appearance
    TAEB->enqueue_message(check => 'discoveries') unless
            TAEB->knowledge->appearance_of->{"amulet of life saving"};
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

# this is nethack's internal representation of strength, to make other
# calculations easier (see include/attrib.h)
sub _nethack_strength {
    my $self = shift;
    my $str = $self->str;

    if ($str =~ /^(\d+)(?:\/(\*\*|\d+))?$/) {
        my $base = $1;
        my $ext  = $2 || 0;
        $ext = 100 if $ext eq '**';

        return $base if $base < 18;
        return 18 + $ext if $base == 18;
        return 100 + $base;
    }
    else {
        TAEB->error("Unable to parse strength $str.");
    }
}

# this is what NetHack uses to convert 18/whackiness to an integer
# or so I think. crosscheck src/attrib.c and src/botl.c..
sub numeric_strength {
    my $self = shift;
    my $str = $self->_nethack_strength;

    return $str if $str <= 18;
    return 19 + int($str / 50) if ($str <= 100 + 21);
    return $str - 100;
}

sub strength_damage_bonus {
    my $self = shift;
    my $str = $self->_nethack_strength;

       if ($str <  6)        { return -1 }
    elsif ($str <  16)       { return 0  }
    elsif ($str <  18)       { return 1  }
    elsif ($str == 18)       { return 2  }
    elsif ($str <= 18 + 75)  { return 3  }
    elsif ($str <= 18 + 90)  { return 4  }
    elsif ($str <  18 + 100) { return 5  }
    else                     { return 6  }
}

sub item_damage_bonus {
    # XXX: include rings of increase damage, etc here
    return 0;
}

=head2 burden_mod

Returns the speed modification imposed by burden.

=cut

sub burden_mod {
    my $self = shift;
    my $burden = $self->burden;

    return 1    if $burden eq 'Unencumbered';
    return .75  if $burden eq 'Burdened';
    return .5   if $burden eq 'Stressed';
    return .25  if $burden eq 'Strained';
    return .125 if $burden eq 'Overtaxed';
    return 0    if $burden eq 'Overloaded';

    die "Unknown burden level ($burden)";
}

=head2 speed_range

Returns the minimum and maximum speed level.

=cut

sub speed_range {
    my $self = shift;
    Carp::croak("Call speed_range in list context") if !wantarray;
    return (18, 24) if $self->is_very_fast;
    return (12, 18) if $self->is_fast;
    return (12, 12);
}

=head2 speed :: (Int,Int)

Returns the minimum and maximum speed of the PC in its current condition.
In scalar context, returns the average.

=cut

sub speed {
    my $self = shift;
    my ($min, $max) = $self->speed_range;
    my $burden_mod = $self->burden_mod;

    $min *= $burden_mod;
    $max *= $burden_mod;

    return ($min + $max) / 2 if !wantarray;
    return ($min, $max);
}

=head2 has_infravision :: Bool

Return true if the PC has infravision.

=cut

sub has_infravision {
    my $self = shift;
    return $self->race ne 'Hum'; # XXX handle polyself
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

    $self->intrinsic_fast(1) if $self->role eq 'Arc'
                             || $self->role eq 'Mon'
                             || $self->role eq 'Sam';
}

sub msg_vault_guard {
    my $self = shift;
    my $following = shift;

    $self->following_vault_guard($following);
}

sub msg_attacked {
    my $self = shift;
    my $attacker = shift;

    if ($attacker =~ /\bnurse\b/) {
        $self->last_seen_nurse($self->turn);
    }
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
        $self->$method(@_);
    }
    else {
        TAEB->warning("I don't know how to check $thing.");
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

sub _check_tile {
    my $self = shift;
    my $x = shift;
    my $y = shift;

    my $msg = TAEB->farlook($x, $y);
    TAEB->enqueue_message('farlooked' => $x, $y, $msg);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


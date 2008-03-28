#!/usr/bin/env perl
package TAEB::ScreenScraper;
use List::Util qw/min max/;
use TAEB::OO;
use NetHack::Menu;

our %msg_string = (
    "You are blinded by a blast of light!" =>
        ['status_change', 'blindness', 1],
    "You can see again." =>
        ['status_change', 'blindness', 0],
    "You feel feverish." =>
        ['status_change', 'lycanthropy', 1],
    "You feel purified." =>
        ['status_change', 'lycanthropy', 0],
    "From the murky depths, a hand reaches up to bless the sword." =>
        ['excalibur'],
    "The fountain dries up!" =>
        ['dungeon_feature', 'fountain dries up'],
    "As the hand retreats, the fountain disappears!" =>
        ['dungeon_feature', 'fountain dries up'],
    "The air around you begins to shimmer with a golden haze." =>
        ['buff', 'protection', 1, +1],
    "The golden haze around you becomes more dense." =>
        ['buff', 'protection', 1, +1],
    "The golden haze around you becomes less dense." =>
        ['buff', 'protection', 1, -1],
    "The golden haze around you disappears." =>
        ['buff', 'protection', 0, -1],
    "You are suddenly moving much faster." =>
        ['buff', 'haste self', 1, +1],
    "Your legs get new energy." =>
        ['buff', 'haste self', 1, +1],
    "You feel yourself slowing down." =>
        ['buff', 'haste self', 0, -1],
    "This door is locked." =>
        ['door', 'locked'],
    "This door resists!" =>
        ['door', 'resists'],
    "You succeed in unlocking the door." =>
        ['door', 'just_unlocked'],
    "You succeed in picking the lock." =>
        ['door', 'just_unlocked'],
    "You stop locking the door." =>
        ['door', 'interrupted_locking'],
    "You stop picking the lock." =>
        ['door', 'interrupted_unlocking'],
    "You stop unlocking the door." =>
        ['door', 'interrupted_unlocking'],
    "There is nothing here to pick up." =>
        ['clear_floor'],
    '"You bit it, you bought it!"' =>
        ['debt' => undef],
    "You have no credit or debt in here." =>
        ['debt', 0],
    "You don't owe any money here." =>
        ['debt', 0],
    "Your stomach feels content." =>
        ['nutrition' => 800],
    "You hear crashing rock." =>
        ['pickaxe'],
    "Nothing happens." =>
        ['nothing_happens'],
    "A few ice cubes drop from the wand." =>
        [wand => 'wand of cold'],
    "The wand unsuccessfully fights your attempt to write!" =>
        [wand => 'wand of striking'],
    "A lit field surrounds you!" =>
        [wand => 'wand of light'],
    "There is a falling rock trap here." =>
        [dungeon_feature => "trap" => "falling rock trap"],
    "Far below you, you see coins glistening in the water." =>
        [floor_item => sub { TAEB->new_item("1 gold piece") }],
    "You wrest one last charge from the worn-out wand." =>
        ['wrest_wand'],
    "You are caught in a bear trap." =>
        ['beartrap'],
    "You can't move your leg!" =>
        ['beartrap'],
    "You can't write on the water!" =>
        [dungeon_feature => 'fountain'],
    "The dish washer returns!" =>
        ['dishwasher'],
    "Muddy waste pops up from the drain." =>
        ['ring_sink'],
    "A black ooze gushes up from the drain!" =>
        ['pudding'],
    "Suddenly one of the Vault's guards enters!" =>
        ['vault_guard' => 1],
    "Suddenly, the guard disappears." =>
        ['vault_guard' => 0],
    "\"You've been warned, knave!\"" =>
        ['vault_guard' => 0],
    "You get expelled!" =>
        [engulfed => 0],
    "You activated a magic portal!" =>
        ['portal'],
    "Something is engraved here on the headstone." =>
        ['dungeon_feature', 'grave'],
);

our @msg_regex = (
    [
        qr/^There is a (staircase (?:up|down)|fountain|sink|grave) here\.$/,
            ['dungeon_feature', sub { $1 }],
    ],
    [
        qr/^You feel more confident in your (?:(weapon|spell casting|fighting) )?skills\.$/,
            [check => 'enhance'],
    ],
    [
        qr/^You cannot escape from (?:the )?(.*)!/,
            ['cannot_escape', sub { $1 || '' }],
    ],
    [
        qr/^You throw (\d+) /,
            ['throw_count', sub { $1 }],
    ],
    [
        qr/^(?:A|Your) bear trap closes on your/,
            ['beartrap'],
    ],
    [
        qr/^You (?:see|feel) here (.*?)\./,
            ['floor_item', sub { TAEB->new_item($1) }],
    ],
    [
        qr/^(. - .*?|\d+ gold pieces?)\.$/,
            ['got_item', sub { TAEB->new_item($1) }],
    ],
    [
        qr/^(. - .*?|\d+ gold pieces?)\.$/,
            ['remove_floor_item', sub { TAEB->new_item($1) }],
    ],
    [
        qr/^You read: \"(.*)\"\./,
            ['floor_message', sub { $1 }],
    ],
    [
        qr/^You owe .*? (\d+) zorkmids?\./,
            ['debt', sub { $1 }],
    ],
    [
        qr/^You do not owe .* anything\./,
            ['debt' => 0],
    ],
    [
        qr/^The engraving on the .*? vanishes!/,
            [wand => map { "wand of $_" } 'teleportation', 'cancellation', 'make invisible'],
    ],
    [
        qr/^The bugs on the .*? stop moving!/,
            [wand => 'wand of death', 'wand of sleep'],
    ],
    [
        # digging, fire, lightning
        qr/^This .*? is a (wand of \S+)!/,
            [wand => sub { $1 }],
    ],
    [
        qr/^The .*? is riddled by bullet holes!/,
            [wand => 'wand of magic missile'],
    ],
    [
        # slow monster, speed monster
        qr/^The bugs on the .*? (slow|speed) (?:up|down)\!/,
            [wand => sub { "wand of $1 monster" }],
    ],
    [
        qr/^The engraving now reads:/,
            [wand => 'wand of polymorph'],
    ],
    [
        qr/^.*? zaps an? .*? wand!/,
            ['check' => 'discoveries'],
    ],
    [
        qr/^"Usage fee, (\d+) zorkmids?\."/,
            [debt => sub { $1 }],
    ],
    [
        qr/ \(unpaid, \d+ zorkmids?\)/,
            [debt => undef],
    ],
    [
        qr/^There are (?:several|many) (?:more )?objects here\./,
            [check => 'floor'],
    ],
    [
        qr/^The .*? stole (.*)\./,
            [lost_item => sub { TAEB->new_item($1) }],
    ],
    [
        qr/^You are (?:almost )?hit by (?:.*)(?:\.!)/,
            [check => 'floor'],
    ],
    [
        qr/"I repeat, (?:drop that gold and )?follow me!"/ =>
            ['vault_guard' => 1],
    ],
    [
        qr/^(.*?) engulfs you!/ =>
            ['engulfed' => 1],
    ],
    [
        qr/^(.*?) reads a scroll of / =>
            [check => 'discoveries'],
    ],
);

our @god_anger = (
    qr/^You feel that .*? is (bummed|displeased)\.$/                   => 1,
    qr/^"Thou must relearn thy lessons!"$/                             => 3,
    qr/^"Thou durst (scorn|call upon) me\?"$/                          => 8,
    qr/^Suddenly, a bolt of lightning strikes you!$/                   => 10000,
    qr/^Suddenly a bolt of lightning comes down at you from the heavens!$/ => 10000,
);

for (my $i = 0; $i < @god_anger; $i += 2) {
    push @msg_regex, [
        $god_anger[$i],
        ['god_angry' => $god_anger[$i+1]],
    ];
}

our @prompts = (
    qr/^What do you want to write with\?/   => 'write_with',
    qr/^What do you want to dip\?/          => 'dip_what',
    qr/^What do you want to dip into\?/     => 'dip_into_what',
    qr/^What do you want to throw\?/        => 'throw_what',
    qr/^What do you want to wield\?/        => 'wield_what',
    qr/^What do you want to use or apply\?/ => 'apply_what',
    qr/^In what direction\?/                => 'what_direction',
    qr/^Lock it\?/                          => 'lock',
    qr/^Unlock it\?/                        => 'unlock',
    qr/^Drink from the (fountain|sink)\?/   => 'drink_from',
    qr/^What do you want to drink\?/        => 'drink_what',
    qr/^What do you want to eat\?/          => 'eat_what',
    qr/^What do you want to zap\?/          => 'zap_what',
    qr/^For what do you wish\?/             => 'wish',
    qr/^Really attack (.*?)\?/              => 'really_attack',
    qr/^\s*Choose which spell to cast/      => 'which_spell',

    qr/^Dip (.*?) into the (fountain|pool of water|water|moat)\?/ => 'dip_into_water',
    qr/^There (?:is|are) (.*?) here; eat (?:it|one)\?/ => 'eat_ground',
    qr/^What do you want to (?:write|engrave|burn|scribble|scrawl) (?:in|into|on) the (.*?) here\?/ => 'write_what',
    qr/^What do you want to add to the writing in the (.*?) here\?/ => 'write_what',
    qr/^Do you want to add to the current engraving\?/ => 'add_engraving',
    qr/^Name an individual object\?/        => 'name_specific',
    qr/^What do you want to (?:call|name)\?/ => 'name_what',
    qr/^Call (.*?):/                        => 'name',
    qr/^What do you want to wear\?/         => 'wear_what',
    qr/^(.*?) for (\d+) zorkmids?\.  Pay\?/ => 'buy_item',
    qr/You did (\d+) zorkmids worth of damage!/ => 'buy_door',
    qr/^"Hello stranger, who are you\?"/ => 'vault_guard',
    qr/^Do you want to keep the save file\?/ => 'save_file',
    qr/^Advance skills without practice\?/ => 'advance_without_practice',
);

our @exceptions = (
    qr/^You don't have that object/             => 'missing_item',
    qr/^You don't have anything to (?:zap|eat)/ => 'missing_item',
    qr/^You are too hungry to cast that spell/  => 'hunger_cast',
);

has messages => (
    isa => 'Str',
);

sub scrape {
    my $self = shift;

    # very big special case
    if (TAEB->vt->row_plaintext(23) =~ /^--More--\s+$/) {
        TAEB->write('        ');
        die "Game over, man!\n";
    }

    eval {
        # You don't have that object!
        $self->handle_exceptions;

        # handle ^X
        $self->handle_attributes;

        # handle --More-- menus
        $self->handle_more_menus;

        # handle menus
        $self->handle_menus;

        # handle --More--
        $self->handle_more;

        # handle other text
        $self->handle_fallback;

        # iterate over the messages, invoke TAEB->enqueue_message for each one
        # we know about
        for my $line ($self->all_messages) {
            if (exists $msg_string{$line}) {
                TAEB->enqueue_message(
                    map { ref($_) eq 'CODE' ? $_->() : $_ }
                    @{ $msg_string{$line} }
                );
            }
            for my $something (@msg_regex) {
                if ($line =~ $something->[0]) {
                    TAEB->enqueue_message(
                        map { ref($_) eq 'CODE' ? $_->() : $_ }
                        @{ $something->[1] }
                    );
                }
            }
        }
    };

    if (($@ || '') =~ /^Recursing screenscraper/) {
        @_ = 'TAEB';
        goto TAEB->can('process_input');;
    }
    elsif ($@) {
        die "$@\n";
    }
}

sub clear {
    my $self = shift;

    $self->messages('');
}

sub handle_exceptions {
    my $response = TAEB->get_exceptional_response(TAEB->topline);
    if (defined $response) {
        TAEB->write($response);
        die "Recursing screenscraper.\n";
    }
}

sub handle_more {
    my $self = shift;

    # while there's a --More-- on the screen..
    while (TAEB->vt->as_string =~ /^(.*?)--More--/) {
        # add the text to the buffer
        # XXX: hack here: replacing all spaces in an engraving with underscores
        # so that our message parsing (which just splits on double spaces)
        # doesn't explode
        my $new_messages = $1;
        $new_messages =~ s{You read: +"(.*)"\.}{
            (my $copy = $1) =~ tr/ /_/;
            q{You read: "} . $copy . q{".}
        }e;

        $self->messages($self->messages . '  ' . $new_messages);

        # try to get rid of the --More--
        TAEB->write(' ');
        die "Recursing screenscraper.\n";
    }
}

sub handle_attributes {
    my $self = shift;

    if (TAEB->topline =~ /^(\s+)Base Attributes/) {
        my $skip = length($1) + 17;

        for ([3, 'name'], [4, 'race'], [11, 'role'], [12, 'gender'], [13, 'align']) {
            my ($row, $method) = @$_;
            my $attribute = substr(TAEB->vt->row_plaintext($row), $skip, 3);
            $attribute = ucfirst lc $attribute;
            TAEB->$method($attribute);
        }

        TAEB->info(sprintf 'It seems we are a %s %s %s %s named %s.', TAEB->role, TAEB->race, TAEB->gender, TAEB->align, TAEB->name);

        TAEB->write(' ');
        die "Recursing screenscraper.\n";
    }
}

sub handle_more_menus {
    my $self = shift;
    my $each;

    if (TAEB->topline =~ /^\s*Discoveries\s*$/) {
        $each = sub {
            my ($identity, $appearance) = /^\s+(.*?) \((.*?)\)/
                or return;
            TAEB->debug("Discovery: $appearance is $identity");
            TAEB->enqueue_message('discovery', $identity, $appearance);
        };
    }
    elsif (TAEB->topline =~ /Things that (?:are|you feel) here:/ || TAEB->vt->row_plaintext(2) =~ /Things that (?:are|you feel) here:/) {
        TAEB->enqueue_message('clear_floor');
        my $skip = 1;
        $each = sub {
            # skip the items until we get "Things that are here" which
            # typically is a message like "There is a door here"
            do { $skip = 0; return } if /^\s*Things that are here:/;
            return if $skip;

            my $item = TAEB->new_item($_);
            TAEB->debug("Adding $item to the current tile.");
            TAEB->enqueue_message('floor_item' => $item);
            return 0;
        };
    }

    if ($each) {
        my $iter = 0;
        while (1) {
            ++$iter;

            # find the first column the menu begins
            my ($endrow, $begincol);
            my $lastrow_contents = TAEB->vt->row_plaintext(TAEB->vt->y);
            if ($lastrow_contents =~ /^(.*?)--More--/) {
                $endrow = TAEB->vt->y;
                $begincol = length $1;
            }
            else {
                die "Recursing screenscraper.\n" if $iter > 1;
                die "Unable to find --More-- on the end row: $lastrow_contents";
            }

            if ($iter > 1) {
                # on subsequent iterations, the --More-- will be in the second
                # column when the menu is continuing
                die "Recursing screenscraper.\n" if $begincol != 1;
            }

            # now for each menu line, invoke the coderef
            for my $row (0 .. $endrow - 1) {
                local $_ = TAEB->vt->row_plaintext($row, $begincol, 80);
                $each->($_);
            }

            # get to the next page of the menu
            TAEB->write(' ');
            TAEB->process_input(0);
        }
    }
}

sub handle_menus {
    my $self = shift;
    my $menu = NetHack::Menu->new(vt => TAEB->vt);

    my $selector;
    my $committer = sub { $menu->commit };

    if (TAEB->topline =~ /Pick up what\?/) {
        TAEB->enqueue_message('clear_floor');
        $selector = sub {
            my $item = TAEB->new_item($_);
            TAEB->enqueue_message('floor_item' => $item);
            TAEB->want_item($item);
        };
    }
    elsif (TAEB->topline =~ /Pick a skill to advance/) {
        $selector = sub {
            my $personality = shift;
            my ($skill, $level) = /^\s*(.*?)\s*\[(.*)\]/
                or warn "Unable to parse $_ as an #enhance item.";
            $personality->enhance($skill, $level);
        };
    }
    elsif (TAEB->topline =~ /Choose which spell to cast/) {
        my $which_spell = TAEB->get_response(TAEB->topline) || "\e";
        $which_spell = ' ' if TAEB->checking eq 'spells';
        $committer = sub { $which_spell };

        $selector = sub {
            my $personality = shift;
            my $slot        = shift;

            # force bolt             1    attack         0%
            my ($name, $forgotten, $fail) =
                /^(.*?)\s+\d([ *])\s+\w+\s+(\d+)%\s*$/
                    or return;

            TAEB->enqueue_message('know_spell',
                $slot, $name, $forgotten eq '*', $fail);

            return 0;
        };
    }
    elsif (TAEB->topline =~ /What would you like to drop\?/) {
        # this one is special: it'll handle updating the inventory
        $selector = sub {
            my $personality = shift;
            my $slot        = shift;
            my $new_item    = TAEB->new_item($_);
            my $item        = TAEB->inventory->get($slot) || $new_item;

            # if we can drop the item, drop it!
            if (!(TAEB->checking eq 'inventory')
            && TAEB->personality->drop($item)) {
                TAEB->inventory->remove($slot);
                TAEB->enqueue_message('floor_item' => $item);
                return 1;
            }

            TAEB->inventory->update($slot, $new_item, 1)
                unless $new_item->appearance eq 'gold piece';
            return 0;
        };
    }

    return unless $menu->has_menu;

    until ($menu->at_end) {
        TAEB->write($menu->next);
        TAEB->process_input(0);
    }

    # wrap selector method so it gets the right $self
    my $wrapper = $selector && sub {
        $selector->(TAEB->personality, @_);
    };

    $menu->select($wrapper) if $wrapper;

    TAEB->write($committer->());
    die "Recursing screenscraper.\n";
}

sub handle_fallback {
    my $self = shift;

    $self->messages($self->messages . '  ' . TAEB->topline);

    if (TAEB->topline =~ /^Really save\? / && TAEB->vt->y == 0) {
        TAEB->write("y");
        die "Game over, man!";
    }

    if (TAEB->vt->y == 0) {
        my $response = TAEB->get_response(TAEB->topline);
        if (defined $response) {
            TAEB->write($response);
            die "Recursing screenscraper.\n";
        }
    }
}

sub all_messages {
    my $self = shift;
    local $_ = $self->messages;
    s/\s+ /  /g;

    return grep { length }
           map { s/^\s+//; s/\s+$//; $_ }
           split /  /, $_;
}

=head2 farlook Int, Int -> (Str | Str, Str, Str, Str)

This will farlook (the C<;> command) at the given coordinates and return
whatever's there.

In scalar context, it will return the plain description string given by
NetHack. In list context, it will return the components: glyph, genus, species,
and how the monster is visible (infravision, telepathy, etc).

WARNING: Since this method interacts with NetHack directly, you cannot use it
in callbacks where there is menu interaction or (in general) any place except
command mode.

=cut

sub farlook {
    my $self = shift;
    my $ex   = shift;
    my $ey   = shift;

    my $directions = $self->crow_flies($ex, $ey);

    TAEB->write(';' . $directions . '.');
    TAEB->process_input;

    # use TAEB->messages as it may consist of multiple lines
    my $description;
    if (TAEB->vt->topline =~ /^\S/) {
        $description = TAEB->vt->topline;
    }
    else {
        $description = TAEB->messages;
    }
    return $description =~ /^(.)\s*(.*?)\s*\((.*)\)\s*(?:\[(.*)\])?\s*$/
        if wantarray;
    return $description;
}

=head2 crow_flies [Int, Int, ]Int, Int -> Str

Returns the vi key directions required to go from where TAEB is to the given
coordinates. If two sets of coordinates are passed in, they will be interpreted
as the "from" coordinates, instead of TAEB's current position.

=cut

sub which_dir {
    my ($dx, $dy) = @_;
    my %dirs = (
        -1 => { -1 => 'y', 0 => 'h', 1 => 'b' },
        0  => { -1 => 'k',           1 => 'j' },
        1  => { -1 => 'u', 0 => 'l', 1 => 'n' },
    );

    my ($sdx, $sdy) = (0, 0);
    $sdx = $dx / abs($dx) if $dx != 0;
    $sdy = $dy / abs($dy) if $dy != 0;
    return ($dirs{$sdx}{$sdy},
            abs($dx) > abs($dy) ? $dirs{$sdx}{0} : $dirs{0}{$sdy});
}

sub crow_flies {
    my $self = shift;
    my $x0 = @_ > 2 ? shift : TAEB->x;
    my $y0 = @_ > 2 ? shift : TAEB->y;
    my $x1 = shift;
    my $y1 = shift;

    my $directions = '';
    my $sub = 0;

    my $dx = $x1 - $x0;
    my $dy = $y1 - $y0;
    my ($diag_dir, $straight_dir) = which_dir($dx, $dy);

    $dx = abs $dx; $dy = abs $dy;

    use integer;
    # Get the minimum number of divisible-by-eight segments
    # to get the number of YUBN diagonal movements to get to the
    # proper vertical or horizontal line
    # This first part will get to within 7
    $sub = min($dx/8, $dy/8);
    $directions .= uc ($diag_dir x $sub);
    $dx -= 8 * $sub;
    $dy -= 8 * $sub;

    # Now move the rest of the way (0..7)
    $sub = min($dx, $dy);
    $directions .= $diag_dir x $sub;
    $dx -= $sub;
    $dy -= $sub;

    # Here we use max because one of the directionals is zero now
    # Otherwise same concept as the first part
    $sub = max($dx/8, $dy/8);
    $directions .= uc ($straight_dir x $sub);
    $dx -= 8 * $sub;
    $dy -= 8 * $sub;

    # Again max, same reason
    $sub = max($dx, $dy);
    $directions .= $straight_dir x $sub;
    # reducing dx/dy isn't needed any more ;)

    return $directions;
}

=for my_sanity
    while ($x + 8 < $x1 && $y - 8 > $y1) { $dir .= 'Y'; $x += 8; $y -= 8 }
    while ($x - 8 > $x1 && $y - 8 > $y1) { $dir .= 'U'; $x -= 8; $y -= 8 }
    while ($x - 8 > $x1 && $y + 8 < $y1) { $dir .= 'B'; $x -= 8; $y += 8 }
    while ($x + 8 < $x1 && $y + 8 < $y1) { $dir .= 'N'; $x += 8; $y += 8 }
    while ($x     < $x1 && $y     > $y1) { $dir .= 'y'; $x++; $y-- }
    while ($x     > $x1 && $y     > $y1) { $dir .= 'u'; $x--; $y-- }
    while ($x     > $x1 && $y     < $y1) { $dir .= 'b'; $x--; $y++ }
    while ($x     < $x1 && $y     < $y1) { $dir .= 'n'; $x++; $y++ }
    while ($x - 8 > $x1) { $dir .= 'H'; $x -= 8 }
    while ($y + 8 < $y1) { $dir .= 'J'; $y += 8 }
    while ($y - 8 > $y1) { $dir .= 'K'; $y -= 8 }
    while ($x + 8 < $x1) { $dir .= 'L'; $x += 8 }
    while ($x     > $x1) { $dir .= 'h'; $x-- }
    while ($y     < $y1) { $dir .= 'j'; $y++ }
    while ($y     > $y1) { $dir .= 'k'; $y-- }
    while ($x     < $x1) { $dir .= 'l'; $x++ }
=cut

__PACKAGE__->meta->make_immutable;
no Moose;

1;


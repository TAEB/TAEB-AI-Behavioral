#!/usr/bin/env perl
package TAEB::ScreenScraper;
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
);

our @msg_regex = (
    [
        qr/^There is a (staircase (?:up|down)) here\.$/,
            ['dungeon_feature', sub { $1 }],
    ],
    [
        qr/^You feel more confident in your (?:(weapon|spell casting|fighting) )?skills\.$/,
            ['powerup', sub { "enhance", $1 || '' }],
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
        qr/^(?:A|Your) bear trap closes on your|You are caught in a bear trap/,
            ['beartrap'],
    ],
    [
        qr/^You see here (.*?)\./,
            ['floor_item', sub { TAEB::World::Item->new_item($1) }],
    ],
    [
        qr/^(. - .*?|\d+ gold pieces?)\.$/,
            ['got_item', sub { TAEB::World::Item->new_item($1) }],
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
    qr/^What do you want to use or apply\?/ => 'apply_what',
    qr/^Lock it\?/                          => 'lock',
    qr/^Unlock it\?/                        => 'unlock',
    qr/^Drink from the (fountain|sink)\?/   => 'drink_from',
    qr/^What do you want to drink\?/        => 'drink_what',
    qr/^What do you want to eat\?/          => 'eat_what',
    qr/^For what do you wish\?/             => 'wish',
    qr/^Really attack (.*?)\?/              => 'really_attack',
    qr/^Call (.*?):/                        => 'call_item',
    qr/^\s*Choose which spell to cast/      => 'which_spell',

    qr/^Dip it into the (fountain|pool of water|water|moat)\?/ => 'dip_into_water',
    qr/^There (?:is|are) (.*?) here; eat (?:it|them)\?/ => 'eat_ground',
    qr/^What do you want to write in the (.*?) here\?/ => 'write_what',
    qr/^What do you want to add to the writing in the (.*?) here\?/ => 'write_what',
    qr/^Do you want to add to the current engraving\?/ => 'add_engraving',
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
        # handle ^X
        $self->handle_attributes;

        # handle menus
        $self->handle_menus;

        # handle --More--
        $self->handle_more;

        # handle other text
        $self->handle_fallback;

        # get rid of all the redundant spaces
        local $_ = $self->messages;
        s/\s+ /  /g;
        $self->messages($_);

        # iterate over the messages, invoke TAEB->enqueue_message for each one
        # we know about
        MESSAGE: for (split /  /, $_) {
            if (exists $msg_string{$_}) {
                TAEB->enqueue_message(
                    map { ref($_) eq 'CODE' ? $_->() : $_ }
                    @{ $msg_string{$_} }
                );
                next MESSAGE;
            }
            for my $something (@msg_regex) {
                if ($_ =~ $something->[0]) {
                    TAEB->enqueue_message(
                        map { ref($_) eq 'CODE' ? $_->() : $_ }
                        @{ $something->[1] }
                    );
                    next MESSAGE;
                }
            }
        }
    };

    if (($@ || '') =~ /^Recursing screenscraper/) {
        TAEB->process_input();
    }
    elsif ($@) {
        die "$@\n";
    }
}

sub clear {
    my $self = shift;

    $self->messages('');
}

sub handle_more {
    my $self = shift;

    # while there's a --More-- on the screen..
    while (TAEB->vt->contains("--More--")) {
        # add the text to the buffer
        $self->messages($self->messages . '  ' . TAEB->topline);

        # try to get rid of the --More--
        TAEB->write(' ');
        die "Recursing screenscraper.\n";
    }
}

sub handle_attributes {
    my $self = shift;

    if (TAEB->topline =~ /^(\s+)Base Attributes/) {
        my $skip = length($1) + 17;

        for ([4, 'race'], [11, 'role'], [12, 'gender'], [13, 'align']) {
            my ($row, $method) = @$_;
            my $attribute = substr(TAEB->vt->row_plaintext($row), $skip, 3);
            $attribute = ucfirst lc $attribute;
            TAEB->$method($attribute);
        }

        TAEB->info(sprintf 'It seems we are a %s %s %s %s.', TAEB->role, TAEB->race, TAEB->gender, TAEB->align);

        TAEB->write(' ');
        die "Recursing screenscraper.\n";
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
            my $item = TAEB::World::Item->new_item($_);
            TAEB->enqueue_message('floor_item' => $item);
            TAEB->want_item($item);
        };
    }
    elsif (TAEB->topline =~ /^\s*Discoveries\s*$/) {
        $menu->select_count('none');
        $selector = sub {
            my ($identity, $appearance) = /^\s+(.*?) \((.*?)\)/
                or return;
            TAEB->debug("Discovery: $appearance is $identity");
            TAEB->enqueue_message('discovery', $identity, $appearance);
        };
    }
    elsif (TAEB->topline =~ /Pick a skill to enhance/) {
        $selector = sub {
            my $personality = shift;
            my ($skill, $level) = /^\s*(.*?)\s*\[(.*)\]/
                or warn "Unable to parse $_ as an #enhance item.";
            $personality->enhance($skill, $level);
        };
    }
    elsif (TAEB->topline =~ /Choose which spell to cast/) {
        my $which_spell = TAEB->get_response(TAEB->topline) || "\e";
        $which_spell = ' ' if TAEB->state eq 'prepare_spells';
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
    elsif (TAEB->topline =~ /Things that are here:/ || TAEB->vt->row_plaintext(2) =~ /Things that are here:/) {
        $menu->select_count('none');
        my $skip = 1;
        TAEB->enqueue_message('clear_floor');
        $selector = sub {
            my $personality = shift;
            my $slot        = shift;

            # skip the items until we get "Things that are here" which
            # typically is a message like "There is a door here"
            do { $skip = 0; return } if /^\s*Things that are here:/;
            return if $skip;

            my $item = TAEB::World::Item->new_item($_);
            TAEB->debug("Adding $item to the current tile.");
            TAEB->enqueue_message('floor_item' => $item);
            return 0;
        };
    }
    elsif (TAEB->topline =~ /You read:/) {
        my $read_text = '';
        if (TAEB->vt->contains("--More--")) {
            my $row = 0;
            do {
                $read_text .= TAEB->vt->row_plaintext($row++);
            } until ($read_text =~ /--More--/);
            $read_text =~ s/.*?You read: \"//;
            $read_text =~ s/\"\.--More--.*?//;
        }
        else {
            $read_text = TAEB->topline;
            $read_text =~ s/.*You read: \"(.*)\"\./$1/;
        }
        my $elbereths = $read_text =~ s/elbereth//gi || 0;
        my $tile = TAEB->current_tile;
        TAEB->info("Tile (".$tile->x.",".$tile->y.") has $elbereths elbereths");
        $tile->elbereths($elbereths);
    }
    elsif (TAEB->topline =~ /What would you like to drop\?/) {
        # this one is special: it'll handle updating the inventory
        $selector = sub {
            my $personality = shift;
            my $slot        = shift;
            my $item        = TAEB::World::Item->new_item($_);

            # if we can drop the item, drop it!
            return 1 if TAEB->personality->drop($item);

            # otherwise, we still have the item, so mark it in our inventory
            TAEB->inventory->update($slot, $item);
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

    $self->messages($self->messages . TAEB->topline);
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

    my $description = TAEB->topline;
    return $description =~ /^(.)\s*(.*?)\s*\((.*)\)\s*(?:\[(.*)\])?\s*$/ if wantarray;
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

make_immutable;
no Moose;

1;


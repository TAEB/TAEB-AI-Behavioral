#!/usr/bin/env perl
package TAEB::ScreenScraper;
use TAEB::OO;
use TAEB::Util qw/crow_flies/;
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
    "You feel quick!" =>
        ['status_change' => fast => 1],
    "You feel slow!" =>
        ['status_change' => fast => 0],
    "You seem faster." =>
        ['status_change' => fast => 1],
    "You seem slower." =>
        ['status_change' => fast => 0],
    "You feel slower." =>
        ['status_change' => fast => 0],
    "You speed up." =>
        ['status_change' => fast => 1],
    "Your quickness feels more natural." =>
        ['status_change' => fast => 1],
    "You are slowing down." =>
        ['status_change' => fast => 0],
    "Your limbs are getting oozy." =>
        ['status_change' => fast => 0],
    "You slow down." =>
        ['status_change' => fast => 0],
    "Your quickness feels less natural." =>
        ['status_change' => fast => 0],
    "\"and thus I grant thee the gift of Speed!\"" =>
        ['status_change' => fast => 1],
    "You slow down." =>
        ['status_change' => very_fast => 0],
    "Your quickness feels less natural." =>
        ['status_change' => very_fast => 0],
    "You are suddenly moving faster." =>
        ['status_change' => very_fast => 1],
    "You are suddenly moving much faster." =>
        ['status_change' => very_fast => 1],
    "Your knees seem more flexible now." =>
        ['status_change' => very_fast => 1],
    "You feel yourself slowing down." =>
        ['status_change' => very_fast => 0],
    "You feel yourself slowing down a bit." =>
        ['status_change' => very_fast => 0],
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
    "There appears to be no shopkeeper here to receive your payment." =>
        ['debt', 0],
    "Your stomach feels content." =>
        ['nutrition' => 900],
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
    "You are stuck to the web." =>
        ['web' => 1],
    "You can't write on the water!" =>
        [dungeon_feature => 'fountain'],
    "There is a broken door here." =>
        [dungeon_feature => 'brokendoor'],
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
    "The heat and smoke are gone." =>
        ['branch', 'vlad'],
    "You smell smoke..." =>
        ['branch', 'gehennom'],
    "A trap door opens up under you!" =>
        ['trapdoor'],
    "There's a gaping hole under you!" =>
        ['trapdoor'],
    "Several flies buzz around the sink." =>
        ['ring' => 'meat ring'],
    "The faucets flash brightly for a moment." =>
        ['ring' => 'ring of adornment'],
    "The sink looks nothing like a fountain." =>
        ['ring' => 'ring of protection from shape changers'],
    "The sink seems to blend into the floor for a moment." =>
        ['ring' => 'ring of stealth'],
    "The water flow seems fixed." =>
        ['ring' => 'ring of sustain ability'],
    "The sink glows white for a moment." =>
        ['ring' => 'ring of warning'],
    "Several flies buzz angrily around the sink." =>
        ['ring' => 'ring of aggravate monster'],
    "The cold water faucet flashes brightly for a moment." =>
        ['ring' => 'ring of cold resistance'],
    "You don't see anything happen to the sink." =>
        ['ring' => 'ring of invisibility'],
    "You see some air in the sink." =>
        ['ring' => 'ring of see invisible'],
    "Static electricity surrounds the sink." =>
        ['ring' => 'ring of shock resistance'],
    "The hot water faucet flashes brightly for a moment." =>
        ['ring' => 'ring of fire resistance'],
    "The sink quivers upward for a moment." =>
        ['ring' => 'ring of levitation'],
    "The sink looks as good as new." =>
        ['ring' => 'ring of regeneration'],
    "The sink momentarily vanishes." =>
        ['ring' => 'ring of teleportation'],
    "You hear loud noises coming from the drain." =>
        ['ring' => 'ring of conflict'],
    "The sink momentarily looks like a fountain." =>
        ['ring' => 'ring of polymorph'],
    "The sink momentarily looks like a regularly erupting geyser." =>
        ['ring' => 'ring of polymorph control'],
    "The sink looks like it is being beamed aboard somewhere." =>
        ['ring' => 'ring of teleport control'],
    "You hear a strange wind." =>
        ['dungeon_level' => 'oracle'],
    "You hear convulsive ravings."  =>
        ['dungeon_level' => 'oracle'],
    "You hear snoring snakes."  =>
        ['dungeon_level' => 'oracle'],
    "You hear someone say \"No more woodchucks!\""  =>
        ['dungeon_level' => 'oracle'],
    "You hear a loud ZOT!"  =>
        ['dungeon_level' => 'oracle'],
    "You enter what seems to be an older, more primitive world." =>
        ['dungeon_level' => 'rogue'],
    "You are being crushed." =>
        ['grabbed' => 1],
    "You get released!" =>
        ['grabbed' => 0],
    "You dig a pit in the floor." =>
        ['pit' => 1],
    "There's not enough room to kick down here." =>
        ['pit' => 1],
    "You can't reach over the edge of the pit." =>
        ['pit' => 1],
    "You float up, out of the pit!" =>
        ['pit' => 0],
    "You crawl to the edge of the pit." =>
        ['pit' => 0],
    "You are still in a pit." =>
        ['pit' => 1],
    "There is a pit here." =>
        ['pit' => 1],
    "You escape a pit." =>
        ['pit' => 0],
    "There's some graffiti on the floor here." =>
        ['engraving_type' => 'graffiti'],
    "You see a message scrawled in blood here." =>
        ['engraving_type' => 'scrawl'],
    "You experience a strange sense of peace." =>
        ['enter_room','temple'],
    "You see no objects here." =>
        ['clear_floor'],
    "You hear the shrill sound of a guard's whistle." =>
        ['angry_watch'],
    "You see an angry guard approaching!" =>
        ['angry_watch'],
    "You're under arrest!" =>
        ['angry_watch'],
    "You are slowing down." =>
        ['status_change', 'stoning', 1],
    "Your limbs are stiffening." =>
        ['status_change', 'stoning', 1],
    "You feel more limber." =>  # praying
        ['status_change', 'stoning', 0],
    "You feel limber!" =>  # consuming acid
        ['status_change', 'stoning', 0],
    "You hear somene cursing shoplifters." =>
        ['level_message', 'shop'],
    "You hear the chime of a cash register." =>
        ['level_message', 'shop'],
    "You hear Neiman and Marcus arguing!" => # hallu
        ['level_message', 'shop'],
    "You hear the footsteps of a guard on patrol." =>
        ['level_message', 'vault'],
    "You hear someone counting money." =>
        ['level_message', 'vault'],
    "You hear someone searching." =>
        ['level_message', 'vault'],
    "Your health currently feels amplified!" =>
        ['resistance_change', 'shock', 1],
    "You feel insulated!" =>
        ['resistance_change', 'shock', 1],
    "You feel grounded in reality." =>
        ['resistance_change', 'shock', 1],
);

our @msg_regex = (
    [
	    qr/^You can't go (?:up|down) here\.$/,
	        ['dungeon_feature', 'bad staircase'],
    ],
    [
        # NetHack will not send "There are no items here." if there is a
        # terrain feature at the current location.  To work around this, we
        # need to clear the floor on receiving notices of terrain... HOWEVER
        # if there were a lot of items, we handle menus before messages.  To
        # avoid a big mess, we skip the clear in that case.
        qr/^There is a.* here.$/,
            [sub { TAEB->scraper->saw_floor_list_this_step ?
                       '' : 'clear_floor' }],  # is this the best way?
    ],
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
        qr/^You fall into (?:a|your) pit!/,
            ['pit' => 1]
    ],
    [
        qr/^You stumble into (?:a|your) spider web!/,
            ['web' => 1]
    ],
    [
        qr/^You (?:see|feel) here (.*?)\./,
            ['floor_item', sub {
                TAEB->enqueue_message('clear_floor');
                TAEB->new_item($1); }],
    ],
    [
        qr/^You feel no objects here\./,
            ['clear_floor']
    ],
    [
        qr/^(. - .*?|\d+ gold pieces?)\.$/,
            ['got_item', sub { TAEB->new_item($1) }],
    ],
    [
        qr/^You read: \"(.*)\"\./,
            ['floor_message', sub { (my $str = $1) =~ tr/_/ /; $str }],
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
        qr/^You (add to the writing|write) in the dust with a.* wand of (create monster|secret door detection)/,
            [wand => sub { "wand of $2" }],
    ],
    [
        qr/^.*? zaps (?:(?:him|her|it)self with )?an? .*? wand!/,
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
        qr/^(?:(?:The .*?)|She|It) (?:steals|stole) (.*)(?:\.|\!)/,
            [lost_item => sub { TAEB->new_item($1) }],
    ],
    [
        qr/^You are (?:almost )?hit by /,
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
        qr/^(.*?) reads a scroll / =>
            [check => 'discoveries'],
    ],
    [
        qr/^(.*?) drinks an? .* potion|^(.*?) drinks a potion called / =>
            [check => 'discoveries'],
    ],
    [
        qr/^Autopickup: (ON|OFF)/ =>
            ['autopickup' => sub { $1 eq 'ON' }],
    ],
    [
        qr/^You (?:kill|destroy) (?:the|an?)(?: invisible)? (.*)(?:\.|!)/ =>
            ['killed' => sub { $1 } ],
    ],
    [
        qr/^Suddenly, .* vanishes from the sink!/ =>
            ['ring' => 'ring of hunger'],
    ],
    [
        qr/^The sink glows (silver|black) for a moment\./ =>
            ['ring' => 'ring of protection'],
    ],
    [
        qr/^The water flow seems (greater|lesser) now.\./ =>
            ['ring' => 'ring of gain constitution'],
    ],
    [
        qr/^The water flow seems (stronger|weaker) now.\./ =>
            ['ring' => 'ring of gain strength'],
    ],
    [
        qr/^The water flow (hits|misses) the drain\./ =>
            ['ring' => 'ring of increase accuracy'],
    ],
    [
        qr/^The water's force seems (greater|smaller) now\./ =>
            ['ring' => 'ring of increase damage'],
    ],
    [
        qr/^You smell rotten (.*)\./ =>
            ['ring' => 'ring of poison resistance'],
    ],
    [
        qr/^You thought your (.*) got lost in the sink, but there it is!/ =>
            ['ring' => 'ring of searching'],
    ],
    [
        qr/^You see (.*) slide right down the drain!/ =>
            ['ring' => 'ring of free action'],
    ],
    [
        qr/(.*) is regurgitated!/ =>
            ['ring' => 'ring of slow digestion'],
    ],
    [
        qr/^You stop eating the (.*)\./ =>
            ['stopped_eating' => sub { $1 } ],
    ],
    [
        qr/You add the .* spell to your repertoire/ =>
            [check => 'spells'],
    ],
    [
        qr/You add the (.*) spell to your repertoire/ =>
            ['check' => 'discoveries'],
    ],
    [
        qr/You add the (.*) spell to your repertoire/ =>
            ['learned_spell' => sub { $1 }],
    ],
    [
        qr/crashes on .* and breaks into shards/ =>
            ['check' => 'discoveries'],
    ],
    [   # Avoid matching shopkeeper name by checking for capital lettering.
        qr/Welcome(?: again)? to(?> [A-Z]\S+)+ ([a-z ]+)!/ =>
            ['enter_room',
             sub {
                (
                    $1 eq 'treasure zoo' ? 'zoo' : 'shop',
                    TAEB::Spoilers::Room->shop_type($1)
                )
             },
            ],
    ],
    [
        qr/You have a(?: strange) forbidding feeling\./ =>
            ['enter_room','temple'],
    ],
    [
        qr/.* (?:grabs|swings itself around) you!/ =>
            ['grabbed' => 1],
    ],
    [
        qr/You cannot escape from .*!/ =>
            ['grabbed' => 1],
    ],
    [
        qr/.* (?:releases you!|grip relaxes\.)/ =>
            ['grabbed' => 0],
    ],
    [
        qr/^Some text has been (burned|melted) into the (?:.*) here\./ =>
            ['engraving_type' => sub { $1 } ],
    ],
    [
        qr/^Something is (written|engraved) here (?:in|on) the (?:.*)\./ =>
            ['engraving_type' => sub { $1 } ],
    ],
    [
        qr/^(?:(?:The )?(.*|Your)) medallion begins to glow!/ =>
            ['life_saving' => sub { $1 } ],
    ],
    [
        qr/^There is an altar to [\w\- ]+ \((law|neu|cha|unaligned)\w*\) here\./ =>
            ['dungeon_feature' => sub {
                (ucfirst($1) eq TAEB->align
                    ? 'coaligned '
                    : 'crossaligned ')
                .'altar'
            } ],
    ],
    [
        qr/^There's a (.*?) hiding under a (.*)!/ =>
            ['hidden_monster' => sub { ($1, $2) } ],
    ],
    [
        qr/^What a pity - you just ruined a future piece of (?:fine )?art!/ =>
            ['status_change', 'stoning', 0],
    ],
    [
        qr/^(.*?) (hits|misses)[.!]$/ =>
            ['attacked' => sub { $1, $2 eq 'hits' } ],
    ],
    [
        qr/^Your .* get new energy\.$/ =>
            [status_change => very_fast => 1],
    ],
    [
        # This one is somewhat tricky.  There is no message for speed ending
        # if you are still very fast due to speed boots, so speed will stay
        # at 'fast'. This causes no harm until the boots are taken off or
        # destroyed; fortunately at that time we receive the following message,
        # which allows us to fix the mistaken speed.
        qr/^You feel yourself slow down.*\.$/ =>
            [status_change => very_fast => 0],
    ],
    [
        qr/^You (?:be chillin'|feel a momentary chill)\.$/ =>
            ['resistance_change', 'fire', 1],
    ],
    [
        qr/^You feel (?:warm\!|full of hot air\.)$/ =>
            ['resistance_change', 'cold', 1],
    ],
    [
        qr/^You feel (?:very firm|totally together, man)\.$/ =>
            ['resistance_change', 'disintegration', 1],
    ],
    [
        qr/^You feel(?: especially)? (?:healthy|hardy)(?:\.|\!)$/ =>
            ['resistance_change', 'poison', 1],
    ],
    [
        qr/^You feel(?: wide)? awake(?:\.|\!)$/ =>
            ['resistance_change', 'sleep', 1],
    ],
    [
        qr/^You're finally finished\./ =>
            ['finally_finished'],
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
    qr/^Talk to whom\? \(in what direction\)/ => 'what_direction',
    qr/^Itemized billing\? \[yn\] \(n\)/    => 'itemized_billing',
    qr/^Lock it\?/                          => 'lock',
    qr/^Unlock it\?/                        => 'unlock',
    qr/^Drink from the (fountain|sink)\?/   => 'drink_from',
    qr/^What do you want to drink\?/        => 'drink_what',
    qr/^What do you want to eat\?/          => 'eat_what',
    qr/^What do you want to zap\?/          => 'zap_what',
    qr/^What do you want to read\?/         => 'read_what',
    qr/^What do you want to rub\?/          => 'rub_what',
    qr/^What do you want to rub on .*?\?/   => 'rub_on_what',
    qr/^For what do you wish\?/             => 'wish',
    qr/^Really attack (.*?)\?/              => 'really_attack',

    qr/^This spellbook is difficult to comprehend/ => 'difficult_spell',

    qr/^Dip (.*?) into the (fountain|pool of water|water|moat)\?/ => 'dip_into_water',
    qr/^There (?:is|are) (.*?) here; eat (?:it|one)\?/ => 'eat_ground',
    qr/^What do you want to (?:write|engrave|burn|scribble|scrawl|melt) (?:in|into|on) the (.*?) here\?/ => 'write_what',
    qr/^What do you want to add to the (?:writing|engraving|grafitti|scrawl|text) (?:in|on|melted into) the (.*?) here\?/ => 'write_what',
    qr/^Do you want to add to the current engraving\?/ => 'add_engraving',
    qr/^Name an individual object\?/        => 'name_specific',
    qr/^What do you want to (?:call|name)\?/ => 'name_what',
    qr/^Call (.*?):/                        => 'name',
    qr/^What do you want to wear\?/         => 'wear_what',
    qr/^What do you want to put on\?/         => 'put_on_what',
    qr/^Which ring-finger, Right or Left\?/   => 'which_finger',
    qr/^(.*?) for (\d+) zorkmids?\.  Pay\?/ => 'buy_item',
    qr/You did (\d+) zorkmids worth of damage!/ => 'buy_door',
    qr/^"Hello stranger, who are you\?"/ => 'vault_guard',
    qr/^How much will you offer\?/      => 'donate',
    qr/^Do you want to keep the save file\?/ => 'save_file',
    qr/^Advance skills without practice\?/ => 'advance_without_practice',
    qr/^Dump core\?/ => 'dump_core',
    qr/^Die\?/ => 'die',
    qr/^Stop eating\?/ => 'stop_eating',
);

our @exceptions = (
    qr/^You don't have that object/             => 'missing_item',
    qr/^You don't have anything to (?:zap|eat)/ => 'missing_item',
    qr/^You are too hungry to cast that spell/  => 'hunger_cast',
);

our @location_requests = (
    qr/^To what position do you want to be teleported\?/ => 'controlled_tele',
);

has messages => (
    isa => 'Str',
);

has old_messages => (
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [] },
);

has parsed_messages => (
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [] },
);

has calls_this_turn => (
    metaclass => 'Counter',
    is        => 'ro',
    provides  => {
        inc   => 'inc_calls_this_turn',
        reset => 'reset_calls_this_turn',
    },
);

has saw_floor_list_this_step => (
    isa       => 'Bool',
    default   => 0,
);

sub scrape {
    my $self = shift;

    $self->check_cycling;

    eval {
        local $SIG{__DIE__};

        # You don't have that object!
        $self->handle_exceptions;

        # handle ^X
        $self->handle_attributes;

        # handle death messages
        $self->handle_death;

        # handle --More-- menus
        $self->handle_more_menus;

        # handle menus
        $self->handle_menus;

        # handle --More--
        $self->handle_more;

        # handle other text
        $self->handle_fallback;

        # handle location requests
        $self->handle_location_request;

        # publish messages for all_messages
        $self->send_messages;

    };

    if (($@ || '') =~ /^Recursing screenscraper/) {
        @_ = 'TAEB';
        goto TAEB->can('process_input');
    }
    elsif ($@) {
        die "$@\n";
    }
}

sub check_cycling {
    my $self = shift;

    $self->inc_calls_this_turn;

    if ($self->calls_this_turn > 500) {
        TAEB->critical("It seems I'm iterating endlessly and making no progress. I'm going to attempt to save and exit!");
        TAEB->save;
    }
}

sub msg_turn {
    my $self = shift;

    $self->reset_calls_this_turn;
}

sub msg_step {
    my $self = shift;

    $self->saw_floor_list_this_step(0);
}

sub clear {
    my $self = shift;

    $self->messages('');
    $self->parsed_messages([]);
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
        $self->messages($self->messages . '  ' . $1);

        # try to get rid of the --More--
        TAEB->write(' ');
        die "Recursing screenscraper.\n";
    }
}

sub handle_attributes {
    my $self = shift;
    my ($method, $attribute);
    if (TAEB->topline =~ /^(\s+)Base Attributes/) {
        my $start = length($1);
        my $skip = $start + 17;

        (my $name = substr(TAEB->vt->row_plaintext(3), $skip)) =~ s/ //g;
        TAEB->name($name);

        # Alignment may end up on line 13 or 14 depending on if we are
        # polymorphed into something with a different gender
        # 4: race  5: role 12: gender 13-14: align
        for (4, 5, 12, 13, 14) {
            next unless my ($method, $attribute) =
                substr(TAEB->vt->row_plaintext($_), $start) =~
                    m/(race|role|gender|align)(?:ment)?\s+: (.*)\b/;
            $attribute = substr($attribute, 0, 3);
            $attribute = ucfirst lc $attribute;
            TAEB->$method($attribute);
        }

        TAEB->info(sprintf 'It seems we are a %s %s %s %s named %s.', TAEB->role, TAEB->race, TAEB->gender, TAEB->align, TAEB->name);
        TAEB->enqueue_message('character', TAEB->name, TAEB->role, TAEB->race,
                                           TAEB->gender, TAEB->align);

        TAEB->write(' ');
        die "Recursing screenscraper.\n";
    }
}

sub handle_more_menus {
    my $self = shift;
    my $each;
    my $line_3 = 0;

    if (TAEB->topline =~ /^\s*Discoveries\s*$/) {
        $each = sub {
            my ($identity, $appearance) = /^\s+(.*?) \((.*?)\)/
                or return;
            TAEB->debug("Discovery: $appearance is $identity");
            TAEB->enqueue_message('discovery', $identity, $appearance);
        };
    }
    elsif (TAEB->topline =~ /Things that (?:are|you feel) here:/
        || ($line_3 = TAEB->vt->row_plaintext(2) =~ /Things that (?:are|you feel) here:/)
    ) {
        $self->messages($self->messages . '  ' . TAEB->topline) if $line_3;
        TAEB->enqueue_message('clear_floor');
        $self->saw_floor_list_this_step(1);
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
        $selector = TAEB->menu_select('pickup');
    }
    elsif (TAEB->topline =~ /Pick a skill to advance/) {
        $selector = TAEB->menu_select('enhance');
    }
    elsif (TAEB->topline =~ /What would you like to identify first\?/) {
        $selector = TAEB->menu_select('identify');
    }
    elsif (TAEB->topline =~ /Choose which spell to cast/) {
        my $which_spell = TAEB->is_checking('spells') ? "\e"
                        : TAEB->single_select('cast') || "\e";
        $committer = sub { $which_spell };

        $selector = sub {
            my $slot = shift;

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
            my $slot        = shift;
            my $new_item    = TAEB->new_item($_);
            my $item        = TAEB->inventory->get($slot) || $new_item;

            # we were unable to parse this item. drop it!
            return 1 if !defined($item);

            # if we can drop the item, drop it!
            if (!(TAEB->is_checking('inventory'))
            && TAEB->personality->drop($item)) {
                TAEB->inventory->remove($slot);
                TAEB->enqueue_message('floor_item' => $item);
                return 1;
            }

            TAEB->inventory->update($slot, $new_item, 1)
                unless $new_item->match(appearance => 'gold piece');
            return 0;
        };
    }

    return unless $menu->has_menu;

    until ($menu->at_end) {
        TAEB->write($menu->next);
        TAEB->process_input(0);
    }

    $menu->select($selector) if $selector;

    TAEB->write($committer->());
    die "Recursing screenscraper.\n";
}

sub handle_fallback {
    my $self = shift;
    my $topline = TAEB->topline;
    $topline =~ s/\s+$/ /;

    if (TAEB->topline =~ /^Really save\? / && TAEB->vt->y == 0) {
        $self->messages($self->messages . '  ' . $topline . 'y');
        TAEB->write("y");
        die "Game over, man!";
    }

    $self->messages($self->messages . '  ' . $topline);

    if (TAEB->vt->y == 0) {
        my $response = TAEB->get_response(TAEB->topline);
        if (defined $response) {
            $self->messages($self->messages . $response);
            TAEB->write($response);
            die "Recursing screenscraper.\n";
        }
        else {
            $self->messages($self->messages . "(escaped)");
            TAEB->write("\e");
            TAEB->warning("Escaped out of unhandled prompt: " . TAEB->topline);
            die "Recursing screenscraper.\n";
        }
    }
}

sub handle_location_request {
    my $self = shift;

    return unless $self->messages =~
        /(?:^\s*|  )(.*?)  \(For instructions type a \?\)\s*$/;
    my $type = $1;

    my $dest = TAEB->get_location_request($type);
    if (defined $dest) {
        $self->messages($self->messages . sprintf "(%d, %d)",
                                                  $dest->x, $dest->y);
        TAEB->write(crow_flies(TAEB->vt->x, TAEB->vt->y,
                               $dest->x, $dest->y) . ".");
        die "Recursing screenscraper.\n";
    }
    else {
        $self->messages($self->messages . "(escaped)");
        TAEB->write("\e");
        TAEB->warning("Escaped out of unhandled location request: " . $type);
        die "Recursing screenscraper.\n";
    }
}

sub handle_death {
    my $name = TAEB->name;
    if (TAEB->topline =~ /^(\s+|Really quit\? \[yn\] \(n\) y\s+)Final Attributes:/) {
        TAEB->debug("I see Final Attributes!");
        TAEB->died;
    }
    elsif (TAEB->dead && TAEB->topline =~ /^Vanquished creatures:/) {
        TAEB->debug("I see Vanquished creatures!");
    }
    elsif (TAEB->dead && TAEB->topline =~ /Voluntary challenges:/) {
        TAEB->debug("I see Voluntary challenges!");
    }
    elsif (TAEB->dead && TAEB->topline =~ /^(?:Goodbye|Farvel|Aloha) $name/) {
        TAEB->debug("I see Goodbye!");

        # there is no pause between displaying the high score table and going
        # back to the dgl menu. this means that if we just wait for the next
        # time screenscraper is called, the only thing we will see is the dgl
        # menu... the high score list will have been overwritten. thus, we have
        # to read/parse it ourselves.
        TAEB->write(' ');
        my $response = TAEB->read;
        my $death_message = '';
        while (1) {
            last unless $response =~ s/^.*?\e\[7m//s;
            $response =~ s/^(.*?)\e\[m//s;
            $death_message .= $1;
        }
        $death_message = join ' ', split ' ', $death_message;
        TAEB->debug("Death message: $death_message");
        my ($rank, $score, $end_reason, $death) = $death_message =~ /^(?:(\d+) )?(\d+) [-\w]+ (\w+) .*?\. (.*?\.)?/;
        TAEB->enqueue_message('death', $rank, $score, $end_reason, $death);
        TAEB->publisher->send_messages;
        die("Game over, man!\n");
    }

    if (TAEB->dead) {
        TAEB->debug("I'm dead! Spacing through the endgame messages...");
        TAEB->write(' ');
        die "Recursing screenscraper.\n";
    }
}

sub all_messages {
    my $self = shift;
    local $_ = $self->messages;
    # XXX: hack here: replacing all spaces in an engraving with underscores
    # so that our message parsing (which just splits on double spaces)
    # doesn't explode
    s{You read: +"(.*)"\.}{
        (my $copy = $1) =~ tr/ /_/;
        q{You read: "} . $copy . q{".}
    }e;
    s/\s+ /  /g;

    my @messages = grep { length }
                   map { s/^\s+//; s/\s+$//; $_ }
                   split /  /, $_;
    return join $_[0], @messages
        if @_;
    return @messages;
}

=head2 send_messages

Iterate over all_messages, invoking TAEB->enqueue_message for each one we know
about.

=cut

sub send_messages {
    my $self = shift;

    for my $line ($self->all_messages) {
        my @messages;

        if (exists $msg_string{$line}) {
            push @messages, [
                map { ref($_) eq 'CODE' ? $_->() : $_ }
                @{ $msg_string{$line} }
            ];
        }

        for my $something (@msg_regex) {
            if ($line =~ $something->[0]) {
                push @messages, [
                    map { ref($_) eq 'CODE' ? $_->() : $_ }
                    @{ $something->[1] }
                ];
            }
        }

        if (@messages) {
            my $msg_names = join ', ', map { $_->[0] } @messages;
            TAEB->debug("Sending '$msg_names' in response to '$line'");
            TAEB->enqueue_message(@$_) for @messages;
        }
        else {
            TAEB->debug("I don't understand this message: $line");
        }

        push @{ $self->parsed_messages }, [$line => scalar @messages];
        push @{ $self->old_messages }, $line;
        shift @{ $self->old_messages } if @{ $self->old_messages } > 100;
    }
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

    my $directions = crow_flies($ex, $ey);

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

__PACKAGE__->meta->make_immutable;
no Moose;

1;


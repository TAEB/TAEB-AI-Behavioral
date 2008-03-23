#!perl
package TAEB;
use TAEB::Util;

use MooseX::Singleton;
use MooseX::AttributeHelpers;

use Log::Dispatch;
use Log::Dispatch::File;

use TAEB::Meta::Types;
use TAEB::Config;
use TAEB::VT;
use TAEB::ScreenScraper;
use TAEB::Spoilers;
use TAEB::Knowledge;
use TAEB::World;
use TAEB::Senses;
use TAEB::Action;
use TAEB::Publisher;

use Module::Refresh;
use Term::ReadKey;

=head1 NAME

TAEB - Tactical Amulet Extraction Bot

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

# report errors to the screen? should only be done while playing NetHack, not
# during REPL or testing
our $ToScreen = 0;

has interface => (
    is       => 'rw',
    isa      => 'TAEB::Interface',
    handles  => [qw/read write/],
);

has personality => (
    is       => 'rw',
    isa      => 'TAEB::AI::Personality',
    handles  => [qw(want_item)],
    trigger  => sub {
        my ($self, $personality) = @_;
        TAEB->info("Now using personality $personality.");
        $personality->institute;
    },
);

has scraper => (
    is       => 'rw',
    isa      => 'TAEB::ScreenScraper',
    required => 1,
    default  => sub { TAEB::ScreenScraper->new },
    handles  => [qw(messages farlook)],
);

has config => (
    is       => 'rw',
    isa      => 'TAEB::Config',
    default  => sub { TAEB::Config->new },
);

has vt => (
    is       => 'rw',
    isa      => 'TAEB::VT',
    required => 1,
    default  => sub {
        my $vt = TAEB::VT->new(cols => 80, rows => 24);
        $vt->option_set(LINEWRAP => 1);
        $vt->option_set(LFTOCRLF => 1);
        return $vt;
    },
    handles  => [qw(topline redraw)],
);

has state => (
    is      => 'rw',
    isa     => 'PlayState',
    default => 'logging_in',
);

has log => (
    is      => 'ro',
    isa     => 'Log::Dispatch',
    lazy    => 1,
    handles => [qw(debug info warning error critical)],
    default => sub {
        my $format = sub {
            my %args = @_;
            chomp $args{message};
            return "[\U$args{level}\E] ".localtime().": $args{message}\n";
        };

        my $dispatcher = Log::Dispatch->new(callbacks => $format);
        for (qw(debug info warning error critical)) {
            $dispatcher->add(
                Log::Dispatch::File->new(
                    name => $_,
                    min_level => $_,
                    filename => "log/$_.log",
                )
            );
        }
        return $dispatcher;
    },
);

my %dungeon_handles;
for my $tiletype (qw/orthogonal diagonal adjacent adjacent_inclusive/) {
    for my $controllertype (qw/each any all/) {
        $dungeon_handles{"${controllertype}_${tiletype}"} =
            "${controllertype}_${tiletype}";
    }
}

has dungeon => (
    is      => 'ro',
    isa     => 'TAEB::World::Dungeon',
    lazy    => 1,
    default => sub { TAEB::World::Dungeon->new },
    handles => {
        current_level => 'current_level',
        current_tile  => 'current_tile',
        map_like      => 'map_like',
        x             => 'x',
        y             => 'y',
        z             => 'z',
        %dungeon_handles,
    },
);

has read_wait => (
    is      => 'rw',
    isa     => 'Int',
    default => -1,
);

has info_to_screen => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has ttyrec => (
    is => 'rw',
    isa => 'GlobRef',
    lazy => 1,
    default => sub {
        require Tie::Handle::TtyRec;
        my ($sec, $min, $hour, $day, $month, $year) = localtime;
        $year += 1900;
        ++$month;

        my $filename = sprintf
            'log/ttyrec/%04d-%02d-%02d.%02d:%02d:%02d.ttyrec',
            $year,
            $month,
            $day,
            $hour,
            $min,
            $sec;

        Tie::Handle::TtyRec->new($filename);
    },
);

has senses => (
    is => 'rw',
    isa => 'TAEB::Senses',
    default => sub { TAEB::Senses->new },
    handles => [qw/hp maxhp power maxpower nutrition level role race gender align turn can_pray can_elbereth checking/],
);

has inventory => (
    is      => 'rw',
    isa     => 'TAEB::World::Inventory',
    default => sub { TAEB::World::Inventory->new },
    handles => {
        find_item => 'find',
    },
);

has spells => (
    is      => 'rw',
    isa     => 'TAEB::World::Spells',
    default => sub { TAEB::World::Spells->new },
    handles => {
        find_spell    => 'find',
        find_castable => 'find_castable',
    },
);

has publisher => (
    is      => 'rw',
    isa     => 'TAEB::Publisher',
    lazy    => 1,
    default => sub { TAEB::Publisher->new },
    handles => [qw/enqueue_message delay_message get_exceptional_response get_response send_at_turn send_in_turns/],
);

has action => (
    is  => 'rw',
    isa => 'Maybe[TAEB::Action]',
);

has knowledge => (
    is      => 'rw',
    isa     => 'TAEB::Knowledge',
    default => sub { TAEB::Knowledge->new },
);

=head2 BUILD

This will initialize L<Module::Refresh>.

=cut

sub BUILD {
    my $self = shift;

    Module::Refresh->refresh;
}

=head2 step

This will perform one input/output iteration of TAEB.

It will return any input it receives, so you can follow along at home.

=cut

sub step {
    my $self = shift;

    TAEB->debug("Starting a new step.");

    $self->full_input(1);
    $self->human_input;

    my $method = "handle_" . $self->state;
    $self->$method;
}

sub handle_playing {
    my $self = shift;

    $self->action->done
        if $self->action && !$self->action->aborted;

    $self->personality->currently('?');
    $self->action($self->personality->next_action);

    my $command = $self->action->command;
    $command =~ s/\n/\\n/g;
    $command =~ s/\e/\\e/g;
    $command =~ s/\cd/^D/g;
    $self->out(
        "\e[23H%s\e[23H\e[K%s (%s)\e[40GN:%d S:%s\e[%d;%dH",
        $self->vt->row_plaintext(22),
        $self->personality->currently,
        $command,
        $self->senses->nutrition,
        ($self->senses->score || '?'),
        $self->y + 1,
        $self->x + 1,
    );

    $self->write($self->action->run);
}

sub handle_logging_in {
    my $self = shift;

    if ($self->vt->contains("Shall I pick a character's ")) {
        TAEB->info("We are now in NetHack, starting a new character.");
        $self->write('n');
    }
    elsif ($self->topline =~ "Choosing Character's Role") {
        $self->write($self->config->get_role);
    }
    elsif ($self->topline =~ "Choosing Race") {
        $self->write($self->config->get_race);
    }
    elsif ($self->topline =~ "Choosing Gender") {
        $self->write($self->config->get_gender);
    }
    elsif ($self->topline =~ "Choosing Alignment") {
        $self->write($self->config->get_alignment);
    }
    elsif ($self->topline =~ "Restoring save file..") {
        TAEB->info("We are now in NetHack, restoring a save file.");
        $self->write(' ');
    }
    elsif ($self->topline =~ "!  You are a" || $self->topline =~ "welcome back to NetHack") {
        $self->enqueue_message('check');
        $self->enqueue_message('game_started');
        $self->state('playing');
    }
    elsif ($self->topline =~ /^\s*It is written in the Book of /) {
        TAEB->error("Using etc/TAEB.nethackrc is MANDATORY");
        $self->write("     \e     #quit\ny         ");
        die "Using etc/TAEB.nethackrc is MANDATORY";
    }
}

sub handle_saving {
    my $self = shift;

    $self->write("\e\eS");
}

=head2 full_input

Run a full input loop, sending messages, updating the screen, and so on.

=cut

sub full_input {
    my $self = shift;
    my $main_call = shift;

    $self->scraper->clear;

    $self->process_input;

    $self->action->post_responses
        if $main_call && $self->action && !$self->action->aborted;

    unless ($self->state eq 'logging_in') {
        $self->dungeon->update;
        $self->senses->update;
        $self->publisher->update;
    }
}

=head2 process_input [Bool]

This will read the interface for input, update the VT object, and print.

It will also return any input it receives.

If the passed in boolean is false, no scraping will occur. If no boolean is
provided, or if the boolean is true, then the scraping will go down.

=cut

sub process_input {
    my $self = shift;
    my $scrape = @_ ? shift : 1;

    my $input = $self->read;

    $self->vt->process($input);
    $self->out($input);

    $self->scraper->scrape
        if $scrape && $self->state ne 'logging_in';

    return $input;
}

sub human_input {
    my $self = shift;

    my $c = Term::ReadKey::ReadKey($self->read_wait)
        unless Scalar::Util::blessed($self->personality) =~ /\bHuman\b/;
    if (defined $c) {
        my $out = $self->keypress($c);
        if (defined $out) {
            $self->out("\e[2H\e[44m$out\e[m");
            sleep 3;
            $self->out($self->redraw);
        }
    }
}

=head2 keypress Str

This accepts a key (such as one typed by the meatbag at the terminal) and does
something with it.

=cut

sub keypress {
    my $self = shift;
    my $c = shift;

    # refresh modules
    if ($c eq 'r') {
        Module::Refresh->refresh;
        return "Modules refreshed. WARNING: This probably doesn't actually work.";
    }

    # pause for a key
    if ($c eq 'p') {
        TAEB->out("\e[2H\e[44mPaused.\e[m");
        Term::ReadKey::ReadKey(0);
        TAEB->out(TAEB->redraw);
        return undef;
    }

    # turn on/off step mode
    if ($c eq 's') {
        my $wait = $self->read_wait($self->read_wait == -1 ? 0 : -1);
        return "Single step mode " . ($wait ? "disabled." : "enabled.");
    }

    # turn on/off info to screen
    if ($c eq 'i') {
        $self->info_to_screen(!$self->info_to_screen);
        return "Info to screen " . ($self->info_to_screen ? "on." : "off.");
    }

    # user input (for emergencies only)
    if ($c eq "\e") {
        $self->write(Term::ReadKey::ReadKey(0));
        return undef;
    }

    # console
    if ($c eq '~') {
        $self->console;

        return;
    }

    if ($c eq 'q') {
        $self->state('saving');
        return "Bye bye then.";
    }

    if ($c eq 'Q') {
        $self->write("\e\e#quit\ny");
        return "Until we meet again, then.";
    }

    if ($c eq ';') {
        my ($z, $y, $x) = (TAEB->z, TAEB->y, TAEB->x);
        while (1) {
            my $tile = TAEB->current_level->at($x, $y);

            # draw some info about the tile at the top
            $self->out("\e[H" . $tile->debug_line);
            $self->out(sprintf "\e[K\e[%d;%dH", $y+1, $x+1);

            # where to next?
            my $c = Term::ReadKey::ReadKey(0);
               if ($c eq 'h') { --$x }
            elsif ($c eq 'j') { ++$y }
            elsif ($c eq 'k') { --$y }
            elsif ($c eq 'l') { ++$x }
            elsif ($c eq 'y') { --$x; --$y }
            elsif ($c eq 'u') { ++$x; --$y }
            elsif ($c eq 'b') { --$x; ++$y }
            elsif ($c eq 'n') { ++$x; ++$y }
            elsif ($c eq 'H') { $x -= 8 }
            elsif ($c eq 'J') { $y += 8 }
            elsif ($c eq 'K') { $y -= 8 }
            elsif ($c eq 'L') { $x += 8 }
            elsif ($c eq 'Y') { $x -= 8; $y -= 8 }
            elsif ($c eq 'U') { $x += 8; $y -= 8 }
            elsif ($c eq 'B') { $x -= 8; $y += 8 }
            elsif ($c eq 'N') { $x += 8; $y += 8 }
            elsif ($c eq '<' || $c eq '>') {
                $c eq '<' ? --$z : ++$z;
                # XXX: redraw screen, change current_level, etc
            }
            elsif ($c eq ';' || $c eq '.' || $c eq "\e"
                || $c eq "\n" || $c eq ' ' || $c eq 'q' || $c eq 'Q') {
                last;
            }

            $x += 80 if $x < 0;
            $y += 24 if $y < 0;

            $x -= 80 if $x >= 80;
            $y -= 24 if $y >= 24;
        }

        # back to normal
        $self->out(TAEB->redraw);
        return;
    }

    # space is always a noncommand
    return if $c eq ' ';

    return "Unknown command '$c'";
}

after qw/info warning/ => sub {
    my ($logger, $message) = @_;

    if (TAEB->info_to_screen && $TAEB::ToScreen) {
        TAEB->out("\e[2H\e[42m$message\e[m");
        sleep 3;
        TAEB->out(TAEB->redraw);
    }
};

# don't squelch warnings entirely during tests
after warning => sub {
    my ($logger, $message) = @_;

    if (!$TAEB::ToScreen) {
        local $SIG{__WARN__};
        warn $message;
    }
};

# we want stack traces for errors and crits
around qw/error critical/ => sub {
    my $orig = shift;
    my ($logger, $message) = @_;

    $logger->$orig(Carp::longmess($message));
};

after qw/error critical/ => sub {
    my ($logger, $message) = @_;

    if ($TAEB::ToScreen) {
        $message = Carp::shortmess($message);
        TAEB->out("\e[2H\e[41m$message\e[m");
        sleep 3;
        TAEB->out(TAEB->redraw);
    }
    else {
        confess $message;
    }
};

sub out {
    my $self = shift;
    my $out = shift;

    if (@_) {
        $out = sprintf $out, @_;
    }

    print $out;

    $self->ttyrec->print($out)
        if TAEB->config->ttyrec;
}

around write => sub {
    my $orig = shift;
    my $self = shift;
    my $text = shift;

    return if length($text) == 0;

    $self->debug("Sending '$text' to NetHack.");
    $orig->($self, $text);
};

# allow the user to say TAEB->personality("human") and have it DTRT
around personality => sub {
    my $orig = shift;
    my $self = shift;

    if (@_ && (my $personality = $self->personality)) {
        $personality->deinstitute;
    }

    if (@_ && $_[0] =~ /^\w+$/) {
        my $name = shift;

        # guess the case unless they tell us what it is (because of ScoreWhore)
        $name = "\L\u$name" if $name eq lc $name;

        $name = "TAEB::AI::Personality::$name";

        (my $file = "$name.pm") =~ s{::}{/}g;
        require $file;

        return $self->$orig($name->new);
    }

    return $self->$orig(@_);
};

sub new_item {
    my $self = shift;
    TAEB::World::Item->new_item(@_);
}

sub new_monster {
    my $self = shift;
    TAEB::World::Monster->new(@_);
}

sub console {
    my $self = shift;

    eval {
        # clear the top half of the screen
        for (1..13) {
            $self->out("\e[${_}H\e[K");
        }
        # silly banner
        $self->out("\e[1;37m+"
            . "\e[1;30m" . ('-' x 50)
            . "\e[1;37m[ "
            . "\e[1;36mT\e[0;36mAEB \e[1;36mC\e[0;36monsole"
            . " \e[1;37m]"
            . "\e[1;30m" . ('-' x 12)
            . "\e[1;37m+"
            . "\e[m");

        # make the top half scroll
        $self->out("\e[1;12r\e[12;1H");

        # turn off Term::ReadKey
        Term::ReadKey::ReadMode(0);

        $ENV{PERL_RL} ||= TAEB->config->readline;

        no warnings 'redefine';
        require Devel::REPL::Script;
        local $TAEB::ToScreen;
        Devel::REPL::Script->new->run;
    };

    # turn on Term::ReadKey
    Term::ReadKey::ReadMode(3);

    # unscroll terminal
    $self->out("\e3");

    # back to normal
    $self->out(TAEB->redraw);
}

no Moose;

1;


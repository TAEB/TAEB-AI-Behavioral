#!perl
package TAEB;
use TAEB::Util ':colors';

use TAEB::OO;

use Log::Dispatch;
use Log::Dispatch::File;

use TAEB::Config;
use TAEB::Display;
use TAEB::VT;
use TAEB::Logger;
use TAEB::ScreenScraper;
use TAEB::Spoilers;
use TAEB::Knowledge;
use TAEB::World;
use TAEB::Senses;
use TAEB::Action;
use TAEB::Publisher;
use TAEB::Debug;

with 'TAEB::Meta::Role::Persistency';
with 'TAEB::Meta::Role::Initialize';

=head1 NAME

TAEB - Tactical Amulet Extraction Bot

=cut

# report errors to the screen? should only be done while playing NetHack, not
# during REPL or testing
our $ToScreen = 0;

class_has persistent_data => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $file = TAEB->persistent_file;
        return {} unless defined $file && -r $file;

        TAEB->log->main("Loading persistency data from $file.");
        return eval { Storable::retrieve($file) } || {};
    },
);

class_has interface => (
    is       => 'rw',
    isa      => 'TAEB::Interface',
    handles  => [qw/read write/],
    lazy     => 1,
    default  => sub {
        use TAEB::Interface::Local;
        TAEB::Interface::Local->new;
    },
);

class_has personality => (
    is       => 'rw',
    isa      => 'TAEB::AI::Personality',
    lazy     => 1,
    default  => sub {
        use TAEB::AI::Personality::Human;
        return TAEB::AI::Personality::Human->new;
    },
    handles  => [qw(want_item currently next_action)],
    trigger  => sub {
        my ($self, $personality) = @_;
        TAEB->log->main("Now using personality $personality.");
        $personality->institute;
    },
);

class_has scraper => (
    is       => 'ro',
    isa      => 'TAEB::ScreenScraper',
    lazy     => 1,
    default  => sub { TAEB::ScreenScraper->new },
    handles  => [qw(parsed_messages all_messages messages farlook)],
);

class_has config => (
    is       => 'ro',
    isa      => 'TAEB::Config',
    lazy     => 1,
    default  => sub { TAEB::Config->new },
);

class_has vt => (
    is       => 'ro',
    isa      => 'TAEB::VT',
    lazy     => 1,
    default  => sub {
        my $vt = TAEB::VT->new(cols => 80, rows => 24);
        $vt->option_set(LINEWRAP => 1);
        $vt->option_set(LFTOCRLF => 1);
        return $vt;
    },
    handles  => [qw(topline)],
);

class_has state => (
    is      => 'rw',
    isa     => 'TAEB::Type::PlayState',
    default => 'logging_in',
);

class_has log => (
    is      => 'ro',
    isa     => 'TAEB::Logger',
    lazy    => 1,
    default => sub { TAEB::Logger->new },
);

class_has dungeon => (
    traits  => [qw/TAEB::Persistent/],
    is      => 'ro',
    isa     => 'TAEB::World::Dungeon',
    default => sub { TAEB::World::Dungeon->new },
    handles => sub {
        my ($attr, $dungeon) = @_;

        my %delegate = map { $_ => $_ }
                       qw{current_level current_tile
                          nearest_level_to nearest_level shallowest_level
                          farthest_level_from farthest_level deepest_level
                          map_like x y z fov};

        for (map { $_->{name} } $dungeon->compute_all_applicable_methods) {
            $delegate{$_} = $_
                if m{
                    ^
                    (?: each | any | all | grep ) _
                    (?: orthogonal | diagonal | adjacent )
                    (?: _inclusive )?
                    $
                }x;
        }

        return %delegate;
    },
);

class_has single_step => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

class_has info_to_screen => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

class_has senses => (
    traits    => [qw/TAEB::Persistent/],
    is        => 'ro',
    isa       => 'TAEB::Senses',
    default   => sub { TAEB::Senses->new },
    handles   => qr/^(?!_check_|msg_|update|initialize)/,
    predicate => 'has_senses',
);

class_has inventory => (
    traits  => [qw/TAEB::Persistent/],
    is      => 'ro',
    isa     => 'TAEB::World::Inventory',
    default => sub { TAEB::World::Inventory->new },
    handles => {
        find_item => 'find',
    },
);

class_has spells => (
    traits  => [qw/TAEB::Persistent/],
    is      => 'ro',
    isa     => 'TAEB::World::Spells',
    default => sub { TAEB::World::Spells->new },
    handles => {
        find_spell    => 'find',
        find_castable => 'find_castable',
        knows_spell   => 'knows_spell',
    },
);

class_has publisher => (
    is      => 'ro',
    isa     => 'TAEB::Publisher',
    lazy    => 1,
    default => sub { TAEB::Publisher->new },
    handles => [qw/enqueue_message get_exceptional_response get_response get_location_request send_at_turn send_in_turns remove_messages menu_select single_select/],
);

class_has action => (
    is        => 'rw',
    isa       => 'TAEB::Action',
    predicate => 'has_action',
);

class_has knowledge => (
    traits  => [qw/TAEB::Persistent/],
    is      => 'ro',
    isa     => 'TAEB::Knowledge',
    default => sub { TAEB::Knowledge->new },
);

class_has new_game => (
    is  => 'rw',
    isa => 'Bool',
    trigger => sub {
        my $self = shift;
        my $new = shift;

        # just in case we missed doing this last time we died
        # we might want some way to prevent all loading from the state file
        # before new_game is called to make this a bit more correct
        $self->destroy_saved_state if $new;

        # by the time we have called new_game, we know whether or not we want
        # to load the class from a state file or from defaults. so, do
        # initialization here that should be done each time the app starts.
        $self->debug("calling initialize");
        $self->initialize;
    },
);

class_has pathfinds => (
    metaclass => 'Counter',
    provides  => {
        inc   => 'inc_pathfinds',
        reset => 'reset_pathfinds',
    },
);

class_has debugger => (
    is      => 'ro',
    isa     => 'TAEB::Debug',
    default => sub { TAEB::Debug->new },
);

class_has display => (
    is      => 'ro',
    isa     => 'TAEB::Display',
    default => sub { TAEB::Display->new },
    handles => ['_notify', 'redraw', 'display_topline', 'place_cursor'],
);

around action => sub {
    my $orig = shift;
    my $self = shift;
    return $orig->($self) unless @_;
    TAEB->publisher->unsubscribe($self->action) if $self->action;
    my $ret = $orig->($self, @_);
    TAEB->publisher->subscribe($self->action);
    return $ret;
};

=head2 iterate

This will perform one input/output iteration of TAEB.

It will return any input it receives, so you can follow along at home.

=cut

sub iterate {
    my $self = shift;

    TAEB->log->main("Starting a new step.");

    $self->full_input(1);
    $self->human_input;

    my $method = "handle_" . $self->state;
    $self->$method;
}

sub handle_playing {
    my $self = shift;

    if ($self->has_action && !$self->action->aborted) {
        $self->action->done;
        $self->publisher->send_messages;
    }

    $self->currently('?');
    $self->reset_pathfinds;
    $self->action($self->next_action);
    TAEB->log->main("Current action: " . $self->action);
    $self->write($self->action->run);
}

sub handle_logging_in {
    my $self = shift;

    if ($self->vt->contains("Shall I pick a character's ")) {
        TAEB->log->main("We are now in NetHack, starting a new character.");
        $self->write('n');
    }
    elsif ($self->topline =~ qr/Choosing Character's Role/) {
        $self->write($self->config->get_role);
    }
    elsif ($self->topline =~ qr/Choosing Race/) {
        $self->write($self->config->get_race);
    }
    elsif ($self->topline =~ qr/Choosing Gender/) {
        $self->write($self->config->get_gender);
    }
    elsif ($self->topline =~ qr/Choosing Alignment/) {
        $self->write($self->config->get_align);
    }
    elsif ($self->topline =~ qr/Restoring save file\.\./) {
        $self->info("We are now in NetHack, restoring a save file.");
        $self->write(' ');
    }
    elsif ($self->topline =~ qr/, welcome( back)? to NetHack!/) {
        $self->new_game($1 ? 0 : 1);
        $self->enqueue_message('check');
        $self->enqueue_message('game_started');
        $self->state('playing');
    }
    elsif ($self->topline =~ /^\s*It is written in the Book of /) {
        TAEB->log->main("Using etc/TAEB.nethackrc is MANDATORY",
                        level => 'error');
        $self->quit;
        die "Using etc/TAEB.nethackrc is MANDATORY";
    }
}

sub handle_saving { shift->save }

=head2 full_input

Run a full input loop, sending messages, updating the screen, and so on.

=cut

sub full_input {
    my $self = shift;
    my $main_call = shift;

    $self->scraper->clear;

    $self->process_input;

    unless ($self->state eq 'logging_in') {
        $self->action->post_responses
            if $main_call && $self->has_action && !$self->action->aborted;

        $self->dungeon->update($main_call);
        $self->senses->update($main_call);
        $self->publisher->update($main_call);

        $self->redraw;
        $self->display_topline;
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

    $self->scraper->scrape
        if $scrape && $self->state ne 'logging_in';

    return $input;
}

sub human_input {
    my $self = shift;

    my $c = $self->single_step ? $self->get_key : $self->try_key
        unless $self->personality->meta->name =~ /\bHuman\b/;

    if (defined $c) {
        my $out = $self->keypress($c);
        if (defined $out) {
            $self->notify($out);
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

    # pause for a key
    if ($c eq 'p') {
        TAEB->notify("Paused.", 0);
        TAEB->get_key;
        TAEB->redraw;
        return undef;
    }

    # turn on/off step mode
    if ($c eq 's') {
        $self->single_step(not $self->single_step);
        return "Single step mode "
             . ($self->single_step ? "enabled." : "disabled.");
    }

    if ($c eq 'd') {
        $self->display->change_draw_mode;
        return undef;
    }

    # turn on/off info to screen
    if ($c eq 'i') {
        $self->info_to_screen(!$self->info_to_screen);
        return "Info to screen " . ($self->info_to_screen ? "on." : "off.");
    }

    # user input (for emergencies only)
    if ($c eq "\e") {
        $self->write($self->get_key);
        return undef;
    }

    # refresh NetHack's screen
    if ($c eq 'r' || $c eq "\cr") {
        # back to normal
        TAEB->redraw(force_clear => 1);
        return undef;
    }

    if ($c eq 'q') {
        $self->state('saving');
        return;
    }

    if ($c eq 'Q') {
        $self->quit;
        return;
    }

    # space is always a noncommand
    return if $c eq ' ';

    $self->enqueue_message('key' => $c);
    return;
}

after qw/info warning/ => sub {
    my ($logger, $message) = @_;

    if (TAEB->info_to_screen && $TAEB::ToScreen) {
        TAEB->notify($message);
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
        TAEB->complain(Carp::shortmess($message));
    }
    else {
        confess $message;
    }
};

sub notify {
    my $self = shift;
    my $msg  = shift;

    $self->_notify($msg, TAEB::Util::COLOR_CYAN, @_);
}

sub complain {
    my $self = shift;
    my $msg  = shift;
    $self->_notify($msg, TAEB::Util::COLOR_RED, @_);
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

sub get_key { Curses::getch }

sub try_key {
    my $self = shift;

    Curses::nodelay(Curses::stdscr, 1);
    my $c = Curses::getch;
    Curses::nodelay(Curses::stdscr, 0);

    return undef if $c eq -1;
    return $c;
}

sub quit {
    my $self = shift;
    $self->write("   \e   \e     #quit\ny");
    # screenscraper handles the message sending and die call
}

sub save {
    my $self = shift;
    $self->write("   \e   \e     Sy");
    $self->enqueue_message('save');
    $self->publisher->send_messages;
    die "See you soon!";
}

sub died {
    my $self = shift;
    $self->dead(1);
    $self->destroy_saved_state;

    # this REALLY prevents us from saving the state file
    $self->config->state_file(undef);
}

sub persistent_file {
    my $self = shift;
    my $state_file = $self->config->state_file;
    return unless defined $state_file;
    return join('-', $state_file, $self->config->interface);
}

__PACKAGE__->meta->make_immutable;
no Moose;
no MooseX::ClassAttribute;

1;


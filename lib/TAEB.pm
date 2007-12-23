#!perl
package TAEB;
use MooseX::Singleton;
use Log::Dispatch;
use Log::Dispatch::File;

use TAEB::Util;
use TAEB::VT;
use TAEB::ScreenScraper;
use TAEB::World;
use TAEB::AI::Senses;

=head1 NAME

TAEB - Tactical Amulet Extraction Bot

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

has interface => (
    is       => 'rw',
    isa      => 'TAEB::Interface',
    handles  => [qw/read write/],
);

has brain => (
    is       => 'rw',
    isa      => 'TAEB::AI::Brain',
    trigger  => sub {
        my ($self, $brain) = @_;
        $brain->institute;
    },
);

has scraper => (
    is       => 'rw',
    isa      => 'TAEB::ScreenScraper',
    required => 1,
    default  => sub { TAEB::ScreenScraper->new },
    handles  => [qw(messages)],
);

has config => (
    is       => 'rw',
    isa      => 'TAEB::Config',
);

has vt => (
    is       => 'rw',
    isa      => 'TAEB::VT',
    required => 1,
    default  => sub { TAEB::VT->new(cols => 80, rows => 24) },
    handles  => [qw(topline redraw)],
);

has logged_in => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has logger => (
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

has dungeon => (
    is      => 'ro',
    isa     => 'TAEB::World::Dungeon',
    lazy    => 1,
    default => sub { TAEB::World::Dungeon->new },
    handles => {
        current_level  => 'current_level',
        current_tile   => 'current_tile',
        map_like       => 'map_like',
        each_adjacent  => 'each_adjacent',
        x              => 'x',
        y              => 'y',
        z              => 'z',
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
    isa => 'TAEB::AI::Senses',
    default => sub { TAEB::AI::Senses->new },
    handles => [qw/hp maxhp hunger/],
);

has saving => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

=head2 step

This will perform one input/output iteration of TAEB.

It will return any input it receives, so you can follow along at home.

=cut

sub step {
    my $self = shift;

    $self->scraper->clear;

    $self->process_input;

    if ($self->logged_in) {
        $self->dungeon->update;
        $self->senses->update;

        my $next_action = $self->saving ? "Sy" : $self->brain->next_action;

        $self->out(
            "\e[23H%s\e[23HCurrently: %s (%s)  \e[%d;%dH",
            $self->vt->row_plaintext(22),
            $self->brain->currently,
            substr($next_action, 0, 5),
            $self->y + 1,
            $self->x + 1,
        );
        $self->brain->currently('?');

        $self->debug("Sending '$next_action' to NetHack.");
        $self->write($next_action);
    }
    else {
        $self->log_in;
    }
}

=head2 log_in

=cut

sub log_in {
    my $self = shift;

    if ($self->vt->contains("Shall I pick a character's ")) {
        $self->write('n');
    }
    elsif ($self->vt->contains("Choosing Character's Role")) {
        $self->write($self->config->get_role);
    }
    elsif ($self->vt->contains("Choosing Race")) {
        $self->write($self->config->get_race);
    }
    elsif ($self->vt->contains("Choosing Gender")) {
        $self->write($self->config->get_gender);
    }
    elsif ($self->vt->contains("Choosing Alignment")) {
        $self->write($self->config->get_alignment);
    }
    elsif ($self->vt->contains("Restoring save file..")) {
        $self->write(' ');
    }
    elsif ($self->vt->contains("!  You are a") || $self->vt->contains("welcome back to NetHack")) {
        $self->logged_in(1);
    }
}

=head2 process_input

This will read the interface for input, update the VT object, and print.

It will also return any input it receives.

=cut

sub process_input {
    my $self = shift;

    my $input = $self->read;

    $self->vt->process($input);
    $self->out($input);

    $self->scraper->scrape
        if $self->logged_in;

    return $input;
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
        if ($INC{"Module/Refresh.pm"}) {
            Module::Refresh->refresh;
            return "Modules refreshed.";
        }

        require Module::Refresh;
        Module::Refresh->refresh;
        return "Modules refreshed. You will have to write and do this again.";
    }

    # pause for a key
    if ($c eq 'p') {
        Term::ReadKey::ReadKey(0);
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

            no warnings 'redefine';
            require Devel::REPL::Script;
            Devel::REPL::Script->new->run;
        };

        # turn on Term::ReadKey
        Term::ReadKey::ReadMode(3);

        # unscroll terminal
        $self->out("\e3");

        # back to normal
        $self->out(TAEB->redraw);

        return;
    }

    if ($c eq 'q') {
        $self->saving(1);
        return "Bye bye then.";
    }

    # space is always a noncommand
    return if $c eq ' ';

    return "Unknown command '$c'";
}

around qw/info warning/ => sub {
    my $orig = shift;
    my ($logger, $message) = @_;

    if (TAEB->info_to_screen) {
        TAEB->out("\e[2H\e[42m$message");
        sleep 3;
        TAEB->out(TAEB->redraw);
    }

    goto $orig;
};

around qw/error critical/ => sub {
    my $orig = shift;
    my ($logger, $message) = @_;

    TAEB->out("\e[2H\e[41m$message");
    sleep 3;
    TAEB->out(TAEB->redraw);

    goto $orig;
};

sub out {
    my $self = shift;
    my $out = shift;

    if (@_) {
        $out = sprintf $out, @_;
    }

    print $out;

    $self->ttyrec->print($out)
        if TAEB->config->contents->{ttyrec};
}

1;


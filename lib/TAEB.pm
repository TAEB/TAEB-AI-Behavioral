#!perl
package TAEB;
use Moose;
use Log::Dispatch;
use Log::Dispatch::File;

use TAEB::Util;
use TAEB::VT;
use TAEB::ScreenScraper;
use TAEB::World;

=head1 NAME

TAEB - Tactical Amulet Extraction Bot

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

has interface =>
(
    is       => 'rw',
    isa      => 'TAEB::Interface',
    required => 1,
);

has brain =>
(
    is       => 'rw',
    isa      => 'TAEB::AI::Brain',
    required => 1,
    trigger  => sub {
        my ($self, $brain) = @_;
        $brain->institute;
    },
);

has scraper =>
(
    is       => 'rw',
    isa      => 'TAEB::ScreenScraper',
    required => 1,
    default  => sub { TAEB::ScreenScraper->new },
    handles  => [qw(messages)],
);

has config =>
(
    is       => 'rw',
    isa      => 'TAEB::Config',
    required => 1,
);

has vt =>
(
    is       => 'rw',
    isa      => 'TAEB::VT',
    required => 1,
    default  => sub { TAEB::VT->new(cols => 80, rows => 24) },
    handles  => [qw(topline redraw)],
);

has logged_in =>
(
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has logger =>
(
    is      => 'ro',
    isa     => 'Log::Dispatch',
    lazy    => 1,
    handles => [qw(debug info warning error critical)],
    default => sub {
        my $format = sub {
            my %args = @_;
            chomp $args{message};
            return "[\U$args{level}\E] $args{message}\n";
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
        update_dungeon => 'update',
        map_like       => 'map_like',
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

=head2 step

This will perform one input/output iteration of TAEB.

It will return any input it receives, so you can follow along at home.

=cut

sub step {
    my $self = shift;

    $self->process_input;

    if ($self->logged_in) {
        $self->scraper->scrape;
        $self->update_dungeon;

        my $next_action = $self->brain->next_action;
        $self->debug("Sending '$next_action' to NetHack.");
        $self->interface->write($next_action);
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
        $self->interface->write('n');
    }
    elsif ($self->vt->contains("Choosing Character's Role")) {
        $self->interface->write($self->config->get_role);
    }
    elsif ($self->vt->contains("Choosing Race")) {
        $self->interface->write($self->config->get_race);
    }
    elsif ($self->vt->contains("Choosing Gender")) {
        $self->interface->write($self->config->get_gender);
    }
    elsif ($self->vt->contains("Choosing Alignment")) {
        $self->interface->write($self->config->get_alignment);
    }
    elsif ($self->vt->contains("Restoring save file..")) {
        $self->interface->write(' ');
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

    my $input = $self->interface->read;

    $self->vt->process($input);
    print $input;

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
        $self->interface->write(Term::ReadKey::ReadKey(0));
        return undef;
    }

    # space is always a noncommand
    return if $c eq ' ';

    return "Unknown command '$c'";
}

around info => sub {
    my $orig = shift;
    my ($logger, $message) = @_;

    if ($main::taeb->info_to_screen) {
        print "\e[2H\e[42m$message";
        sleep 3;
        print $main::taeb->redraw;
    }

    goto $orig;
};

around qw/warning error critical/ => sub {
    my $orig = shift;
    my ($logger, $message) = @_;

    print "\e[2H\e[41m$message";
    sleep 3;
    print $main::taeb->redraw;

    goto $orig;
};

1;


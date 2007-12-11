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
        $brain->institute($self);
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
    handles  => [qw(topline)],
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
        update_dungeon => 'update',
    },
);

=head2 step

This will perform one input/output iteration of TAEB.

It will return any input it receives, so you can follow along at home.

=cut

sub step {
    my $self = shift;

    my $input = $self->process_input;

    if ($self->logged_in) {
        $input .= $self->scraper->scrape($self);
        $self->update_dungeon($self);

        my $next_action = $self->brain->next_action($self);
        $self->debug("Sending '$next_action' to NetHack.");
        $self->interface->write($next_action);
    }
    else {
        $self->log_in;
    }

    return '' if !defined $input;
    return $input;
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

This will read the interface for input and update the VT object.

It will return any input it receives, so C<step> can follow along at home.

=cut

sub process_input {
    my $self = shift;

    my $input = $self->interface->read;

    $self->vt->process($input);

    return $input;
}

1;


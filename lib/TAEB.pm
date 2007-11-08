#!perl
package TAEB;
use Moose;
use TAEB::Util;
use TAEB::VT;
use Log::Dispatch;
use Log::Dispatch::File;

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
    handles  => 'topline',
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
        for (qw/debug info/) {
            $dispatcher->add(
                Log::Dispatch::File->new(
                    name => "$_.log",
                    min_level => $_,
                    filename => "$_.log",
                )
            );
        }
        return $dispatcher;
    },
);

=head2 step

This will perform one input/output iteration of TAEB.

It will return any input it receives, so you can follow along at home.

=cut

sub step {
    my $self = shift;

    my $input = $self->process_input;

    if ($self->vt->contains("--More--")) {
        $self->interface->write(' ');
    }
    elsif ($self->logged_in) {
        if ($self->vt->matches(qr/\((?:end|\d+ of \d+)\)/)) {
            $self->interface->write(' ');
        }
        else {
            my $next_action = $self->brain->next_action($self);
            $self->debug("Sending '$next_action' to NetHack.");
            $self->interface->write($next_action);
        }
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


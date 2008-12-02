#!/usr/bin/perl
use strict;
use warnings;
package TAEB::Logger;
use TAEB::OO;
use Carp;
extends 'Log::Dispatch::Channels';

has turn_calculator => (
    isa     => 'CodeRef',
    default => sub { sub { "-" } },
);

has name_calculator => (
    isa     => 'CodeRef',
    default => sub { sub { '?' } },
);

has default_channels => (
    isa     => 'ArrayRef[Str]',
    default => sub { [qw/everything warning error/] },
);

has bt_levels => (
    isa     => 'HashRef',
    default => sub { { error => 1, warning => 1 } },
);

has everything => (
    isa     => 'Log::Dispatch::File',
    is      => 'ro',
    default => sub {
        my $self = shift;
        Log::Dispatch::File->new(
            name      => 'everything',
            min_level => 'debug',
            filename  => "log/everything.log",
            callbacks => sub { $self->_format('everything', @_) },
        )
    },
);

has warning => (
    isa     => 'Log::Dispatch::File',
    is      => 'ro',
    default => sub {
        my $self = shift;
        Log::Dispatch::File->new(
            name      => 'warning',
            min_level => 'warning',
            filename  => "log/warning.log",
            callbacks => sub { $self->_format('warning', @_) },
        )
    },
);

has error => (
    isa     => 'Log::Dispatch::File',
    is      => 'ro',
    default => sub {
        my $self = shift;
        Log::Dispatch::File->new(
            name      => 'error',
            min_level => 'error',
            filename  => "log/error.log",
            callbacks => sub { $self->_format('error', @_) },
        )
    },
);

has twitter => (
    isa     => 'Maybe[Log::Dispatch::Twitter]',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return undef unless TAEB->config->twitter;
        my $error_config = TAEB->config->twitter->{errors};
        return undef unless $error_config;
        require Log::Dispatch::Twitter;
        my $twitter = Log::Dispatch::Twitter->new(
            name      => 'twitter',
            min_level => 'error',
            username  => $error_config->{username},
            password  => $error_config->{password},
            callbacks => sub {
                my %args = @_;
                return if $args{message} =~ /^Game over/;

                # XXX: we need to not throw errors when we die
                return if $args{message} =~ /^Unable to parse the (botl|status)/;

                $args{message} =~ s/\n.*//s;
                return sprintf "%s (T%s): %s",
                            $self->name_calculator->(),
                            $self->turn_calculator->(),
                            $args{message};
            },
        )
        push @{ $self->default_channels }, 'twitter';
        return $twitter;
    },
);

after new => sub { $self->twitter };

around twitter => sub {
    my $orig = shift;
    my $self = shift;
    my $output = $self->$orig();
    return $output unless @_;
    my $message = shift;
    $output->log(level => 'error', message => $message, @_);
};

around [qw/everything warning error/] => sub {
    my $orig = shift;
    my $self = shift;
    die "Don't log directly to the catch-all loggers" if @_;
    return $self->$orig();
};

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $message = shift;
    my $channel_name = $AUTOLOAD;
    my $channel = $self->channel($channel_name);
    if (!$channel) {
        # XXX: would be nice if LDC had global callbacks
        $self->add_channel($channel_name,
                           callbacks => sub {
                               my %args = @_;
                               if ($self->bt_levels->{$args{level}}) {
                                   return Carp::longmess($args{message});
                               }
                               else {
                                   return $args{message};
                               }
                           });
        $self->add(Log::Dispatch::File->new(
                       name      => $channel_name,
                       min_level => 'debug',
                       filename  => "log/$channel_name.log",
                       callbacks => sub { $self->_format($channel_name, @_) },
                   ),
                   channels => $channel_name);
        $self->_add_default_outputs($channel_name);
    }
    $self->log(channels => $channel_name,
               level    => 'debug',
               message  => $message,
               @_);
}

sub _add_default_outputs {
    my $self = shift;
    my $channel_name = shift;

    for my $name (@{ $self->default_outputs }) {
        $self->add($self->output($name), channels => $channel_name);
    }
}

sub _format {
    my $self = shift;
    my $channel_name = shift;
    my %args = @_;
    chomp $args{message};
    return sprintf "[%s:%s] <T%s> %s: %s\n",
                   uc($args{level}),
                   $channel_name,
                   $self->turn_calculator->(),
                   scalar(localtime),
                   $args{message};
}

1;

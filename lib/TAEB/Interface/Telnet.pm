#!/usr/bin/env perl
package TAEB::Interface::Telnet;
use Moose;
use IO::Socket::Telnet;

=head1 NAME

TAEB::Interface::Telnet - how TAEB talks to nethack.alt.org

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

extends 'TAEB::Interface';

has server => (
    is => 'rw',
    isa => 'Str',
    default => 'nethack.alt.org',
);

has account => (
    is => 'ro',
    isa => 'Str',
);

has password => (
    is => 'ro',
    isa => 'Str',
);

has socket => (
    is => 'rw',
    isa => 'IO::Socket::Telnet',
);

sub BUILD {
    my $self = shift;

    # this has to be done in BUILD because it needs server
    my $socket = IO::Socket::Telnet->new(PeerAddr => $self->server);
    die "Unable to connect to " . $self->server . ": $!"
        if !defined($socket);

    $socket->telnet_simple_callback(\&telnet_negotiation);
    $self->socket($socket);

    print { $socket } join '', 'l',
                               $self->account,  "\n",
                               $self->password, "\n",
                               'p';
}

=head2 read -> STRING

This will read from the socket. It will die if an error occurs.

It will return the input read from the socket.

=cut

sub read {
    my $self = shift;
    my $buffer;

    defined $self->socket->recv($buffer, 4096, 0)
        or die "Disconnected from server: $!";

    return $buffer;
}

=head2 write STRING

This will write to the socket.

=cut

sub write {
    my $self = shift;
    my $text = shift;

    print {$self->socket} $text;
}

=head2 telnet_negotiation OPTION

This is a helper function used in conjunction with IO::Socket::Telnet. In
short, all nethack.alt.org expects us to answer affirmatively is TTYPE (to
which we respond xterm-color) and NAWS (to which we respond 80x24). Everything
else gets a response of DONT or WONT.

=cut

sub telnet_negotiation {
    my $self = shift;
    my $option = shift;

    if ($option =~ /DO TTYPE/) {
        return join '',
               chr(255), # IAC
               chr(251), # WILL
               chr(24),  # TTYPE

               chr(255), # IAC
               chr(250), # SB
               chr(24),  # TTYPE
               chr(0),   # IS
               "xterm-color",
               chr(255), # IAC
               chr(240), # SE
    }

    if ($option =~ /DO NAWS/) {
        return join '',
               chr(255), # IAC
               chr(251), # WILL
               chr(31),  # NAWS

               chr(255), # IAC
               chr(250), # SB
               chr(31),  # NAWS
               chr(0),   # IS
               chr(80),  # 80
               chr(0),   # x
               chr(24),  # 24
               chr(255), # IAC
               chr(240), # SE
    }

    return 0;
}

1;


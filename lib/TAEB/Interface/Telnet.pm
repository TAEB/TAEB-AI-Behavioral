#!/usr/bin/env perl
package TAEB::Interface::Telnet;
use Moose;
use IO::Socket::Telnet;

extends 'TAEB::Interface';

has socket => (
    is => 'rw',
    isa => 'IO::Socket::Telnet',
    default => sub {
        my $socket = IO::Socket::Telnet->new(PeerAddr => 'nethack.alt.org');
        $socket->telnet_simple_callback(\&telnet_negotiation);
        return $socket;
    },
);

sub read {
    my $self = shift;
    my $buffer;

    defined $self->socket->recv($buffer, 4096, 0)
        or die "Disconnected from server: $!";

    return $buffer;
}

sub write {
    my $self = shift;
    my $text = shift;

    print {$self->socket} $text;
}

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


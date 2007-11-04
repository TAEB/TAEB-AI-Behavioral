#!/usr/bin/env perl
package TAEB::Interface::Local;
use Moose;
use IO::Pty::Easy;

extends 'TAEB::Interface';

has pty => (
    is => 'rw',
    isa => 'IO::Pty::Easy',
    default => sub {
        my $pty = IO::Pty::Easy->new;
        $pty->spawn('nethack');
        return $pty;
    },
);

sub read {
    my $self = shift;
    my $out = $self->pty->read();
    die "Pty closed." if $out eq '';
    return $out;
}

sub write {
    my $self = shift;
    my $text = shift;

    my $chars = $self->pty->write();
    die "Pty closed." if $chars == 0;
    return $chars;
}

1;


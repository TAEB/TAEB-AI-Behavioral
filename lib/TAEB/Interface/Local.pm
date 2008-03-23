#!/usr/bin/env perl
package TAEB::Interface::Local;
use TAEB::OO;
use IO::Pty::Easy;
use Time::HiRes 'sleep';

=head1 NAME

TAEB::Interface::Telnet - how TAEB talks to a local nethack

=head1 VERSION

Version 0.01 released ???

=cut

extends 'TAEB::Interface';

has name => (
    isa => 'Str',
    default => 'nethack',
);

has pty => (
    isa => 'IO::Pty::Easy',
);

sub BUILD {
    my $self = shift;

    chomp(my $pwd = `pwd`);
    local $ENV{NETHACKOPTIONS} = '@' . join '/', $pwd, 'etc', 'TAEB.nethackrc';

    # this has to be done in BUILD because it needs name
    my $pty = IO::Pty::Easy->new;
    $pty->spawn($self->name);
    $self->pty($pty);
}

=head2 read -> STRING

This will read from the pty. It will die if an error occurs.

It will return the input read from the pty.

=cut

sub read {
    my $self = shift;

    # this is about the best we can do for consistency
    # in Telnet we have a complicated ping/pong that scales with network latency
    sleep(0.2);

    die "Pty inactive." unless $self->pty->is_active;
    my $out = $self->pty->read(1);
    return '' if !defined($out);
    die "Pty closed." if $out eq '';
    return $out;
}

=head2 write STRING

This will write to the pty. It will die if an error occurs.

=cut

sub write {
    my $self = shift;
    my $text = shift;

    TAEB->error("Called TAEB->write with no text.") if length($text) == 0;

    die "Pty inactive." unless $self->pty->is_active;
    my $chars = $self->pty->write($text, 1);
    return if !defined($chars);

    die "Pty closed." if $chars == 0;
    return $chars;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


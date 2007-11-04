#!/usr/bin/env perl
package TAEB::Interface::Local;
use Moose;
use IO::Pty::Easy;

=head1 NAME

TAEB::Interface::Telnet - how TAEB talks to a local nethack

=head1 VERSION

Version 0.01 released ???

=cut

extends 'TAEB::Interface';

has name => (
    is => 'rw',
    isa => 'Str',
    default => 'nethack',
);

has pty => (
    is => 'rw',
    isa => 'IO::Pty::Easy',
);

sub BUILD {
    my $self = shift;

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
    die "Pty inactive." unless $self->pty->is_active;
    my $out = $self->pty->read();
    die "Pty closed." if $out eq '';
    return $out;
}

=head2 write STRING

This will write to the pty. It will die if an error occurs.

=cut

sub write {
    my $self = shift;
    my $text = shift;

    die "Pty inactive." unless $self->pty->is_active;
    my $chars = $self->pty->write($text);
    die "Pty closed." if $chars == 0;
    return $chars;
}

1;


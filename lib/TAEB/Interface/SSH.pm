#!/usr/bin/env perl
package TAEB::Interface::SSH;
use TAEB::OO;

=head1 NAME

TAEB::Interface::SSH - how TAEB talks to /dev/null

=cut

extends 'TAEB::Interface::Local';

has server => (
    isa     => 'Str',
    default => 'nethack1.devnull.net',
);

has account => (
    isa => 'Str',
);

has password => (
    isa => 'Str',
);

sub _build_pty {
    my $self = shift;

    TAEB->debug("Connecting to " . $self->server . ".");

    my $pty = IO::Pty::Easy->new;
    $pty->spawn('ssh', $self->server, '-l', $self->account);
    $pty->write($self->password . "\n\n");

    TAEB->debug("Connected to " . $self->server . ".");

    return $pty;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


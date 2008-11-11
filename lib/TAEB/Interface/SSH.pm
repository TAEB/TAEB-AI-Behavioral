#!/usr/bin/env perl
package TAEB::Interface::SSH;
use TAEB::OO;

use constant ping_wait => .3;

=head1 NAME

TAEB::Interface::SSH - how TAEB talks to /dev/null

=cut

extends 'TAEB::Interface::Local';

has server => (
    isa     => 'Str',
    default => 'devnull.kraln.com',
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

    alarm 20;
    eval {
        local $SIG{ALRM} = sub { die "timeout" };

        my $output = '';
        while (1) {
            $output .= $pty->read(0) || '';
            if ($output =~ /password/) {
                alarm 0;
                last;
            }
        }
    };

    die "Died ($@) while waiting for password prompt.\n" if $@;

    $pty->write($self->password . "\n\n", 0);

    TAEB->debug("Connected to " . $self->server . ".");

    return $pty;
}

around read => sub {
    my $orig = shift;

    return join '', map { $orig->(@_) } 1 .. 3;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;


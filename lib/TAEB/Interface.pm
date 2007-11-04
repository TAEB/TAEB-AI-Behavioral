#!/usr/bin/env perl
package TAEB::Interface;
use Moose;

=head1 NAME

TAEB::Interface - how TAEB talks to NetHack

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head2 read -> STRING

This will read from the interface. It's quite OK to block and throw errors
in this method.

It should just return the string read from the interface.

Your subclass B<must> override this method.

=cut

sub read    { die "You must override the 'read' method in TAEB::Interface."  }

=head2 write STRING

This will write to the interface. It's quite OK to block and throw errors
in this method.

Its return value is currently ignored.

Your subclass B<must> override this method.

=cut

sub write   { die "You must override the 'write' method in TAEB::Interface." }

1;


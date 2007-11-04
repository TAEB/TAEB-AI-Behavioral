#!/usr/bin/env perl
package TAEB::Brain;
use Moose;

=head1 NAME

TAEB::Brain - how TAEB tactically extracts its amulets

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head2 next_action TAEB -> STRING

This is the method called by the main TAEB code to get individual commands.
It will be called with a C<$self> which will be your TAEB::Brain object, and
a TAEB object for interacting with the rest of the system (such as for looking
at the map).

It should just return the string to send to NetHack.

Your subclass B<must> override this method.

=cut

sub next_action {
    die "You must override the 'next_action' method in TAEB::Brain.";
}

1;


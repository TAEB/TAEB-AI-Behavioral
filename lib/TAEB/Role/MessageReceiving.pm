#!/usr/bin/env perl
package TAEB::Role::MessageReceiving;
use Moose::Role;

=head1 NAME

TAEB::Meta::MessageReceiving - role for subscribing to NetHack messages

=cut

=head1 DESCRIPTION

=head1 CALLBACKS

=head2 msg_status_change Str[, Bool]

TAEB's status has changed. The first argument is a string representation
of the status that changed, and the second argument, when applicable, indicates
whether TAEB gained or lost the status. For example, when the message "You are
blinded by a blast of light!" is received, this method will be invoked with
the first argument "blindness" and the second argument true. When the message
"You can see again." is received, this method will be invoked with the
first argument "blindness" and the second argument false.

=cut

sub msg_status_change { }

1;


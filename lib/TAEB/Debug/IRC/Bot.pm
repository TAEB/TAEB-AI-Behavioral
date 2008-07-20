#!/usr/bin/perl
use strict;
use warnings;
package TAEB::Debug::IRC::Bot;
use base 'Bot::BasicBot';
use POE::Kernel;

sub init {
    # does nothing (the irc component isn't initialized yet), but shuts up
    # warnings about run never being called
    $poe_kernel->run;
    # have to return true
    1;
}

sub step {
    while ($poe_kernel->get_next_event_time - time < 0) {
        TAEB->debug("IRC: running a timeslice");
        $poe_kernel->run_one_timeslice;
    }
}

sub chanjoin {
    my $self = shift;
    $self->say(channel => $self->channels,
               body    => sprintf "Hi! I'm a %s-%s-%s-%s",
                                  TAEB->role,   TAEB->race,
                                  TAEB->gender, TAEB->align);
}

sub log {
    my $self = shift;
    for (@_) {
        chomp;
        TAEB->debug($_);
    }
}

1;

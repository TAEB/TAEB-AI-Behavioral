#!/usr/bin/perl
use strict;
use warnings;
package TAEB::Debug::IRC::Bot;
use base 'Bot::BasicBot';
use POE::Kernel;
use Time::HiRes qw/time/;

sub init {
    # does nothing (the irc component isn't initialized yet), but shuts up
    # warnings about run never being called
    $poe_kernel->run;
    # have to return true
    1;
}

sub step {
    my $self = shift;

    do {
        TAEB->debug("IRC: running a timeslice at ".time);
        local $SIG{__DIE__};
        $self->schedule_tick(0.05);
        $poe_kernel->run_one_timeslice;
    } while ($poe_kernel->get_next_event_time - time < 0);
}

sub chanjoin {
    my $self = shift;
    $self->say(channel => $self->channels,
               body    => sprintf "Hi! I'm a %s-%s-%s-%s",
                                  TAEB->role,   TAEB->race,
                                  TAEB->gender, TAEB->align);
}

sub said {
    my $self = shift;
    my %args = %{ $_[0] };
    return unless $args{address};

    TAEB->debug("Somebody is talking to us! ($args{who}, $args{body})");
    if ($args{body} =~ /^where/i) {
        return sprintf "%s %s", TAEB->current_tile, TAEB->current_level;
    }
    elsif ($args{body} =~ /^score/i) {
        return TAEB->score;
    }
    elsif ($args{body} =~ /^who/i) {
        return sprintf "%s (%s %s %s %s)", TAEB->name, TAEB->role, TAEB->race,
                                           TAEB->gender, TAEB->align;
    }
}

sub log {
    my $self = shift;
    for (@_) {
        chomp;
        TAEB->debug($_);
    }
}

1;

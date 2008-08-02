#!/usr/bin/perl
package TAEB::Debug::IRC::Bot;
use TAEB::OO;
use POE::Kernel;
use Time::HiRes qw/time/;

extends 'Bot::BasicBot';
with 'TAEB::Debug::Bot';

sub initialize {
    # does nothing (the irc component isn't initialized yet), but shuts up
    # warnings about run never being called
    $poe_kernel->run;
}

sub speak {
    my $self = shift;
    my $msg  = shift;

    $self->say(
        channel => $self->channels,
        body    => $msg,
    );
}

sub tick {
    my $self = shift;

    TAEB->debug("Iterating the IRC component");

    do {
        TAEB->debug("IRC: running a timeslice at ".time);
        local $SIG{__DIE__};
        $self->schedule_tick(0.05);
        $poe_kernel->run_one_timeslice;
    } while ($poe_kernel->get_next_event_time - time < 0);
}

sub said {
    my $self = shift;
    my %args = %{ $_[0] };
    return unless $args{address};

    TAEB->debug("Somebody is talking to us! ($args{who}, $args{body})");
    return $self->response_to($args{body});
}

sub log {
    my $self = shift;
    for (@_) {
        chomp;
        TAEB->debug($_);
    }
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
no Moose;

1;

#!/usr/bin/perl
package TAEB::Debug::IRC::Bot;
use TAEB::OO;
extends 'Bot::BasicBot';
use POE::Kernel;
use Time::HiRes qw/time/;

has paused => (
    isa     => 'Bool',
    default => 0,
);

sub init {
    # does nothing (the irc component isn't initialized yet), but shuts up
    # warnings about run never being called
    $poe_kernel->run;
    # have to return true
    1;
}

sub msg_step {
    my $self = shift;

    TAEB->debug("Iterating the IRC component");
    do {
        TAEB->debug("IRC: running a timeslice at ".time);
        local $SIG{__DIE__};
        $self->schedule_tick(0.05);
        $poe_kernel->run_one_timeslice;
    } while ($poe_kernel->get_next_event_time - time < 0 || $self->paused);
}

sub msg_death {
    my $self = shift;
    my ($rank, $score, $end_reason, $death) = @_;
    $self->quit_message(sprintf "%s (%s %s %s %s), %d points, %s",
                                TAEB->name, TAEB->role, TAEB->race,
                                TAEB->gender, TAEB->align, TAEB->score,
                                $death || $end_reason);
}

sub msg_save {
    my $self = shift;
    $self->quit_message("Saving...");
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
    elsif ($args{body} =~ /^pause/i) {
        $self->paused(1);
        TAEB->notify('Paused (IRC)', 0);
        return 'Paused';
    }
    elsif ($args{body} =~ /^unpause/i) {
        $self->paused(0);
        return 'Unpaused';
    }
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

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

has _watching_methods => (
    metaclass => 'Set::Object',
    provides => {
        insert   => 'watch_message',
        remove   => 'unwatch_message',
        elements => 'watching_messages',
    },
);

before watch_message => sub {
    my $self = shift;
    my $msg = shift;
    $self->meta->add_method('msg_'.$msg => sub {
        $self->say(channel => $self->channels,
                   body    => "I received a $msg message");
        shift->unwatch_message($msg);
    });
};

after unwatch_message => sub {
    my $self = shift;
    my $msg = shift;
    $self->meta->remove_method('msg_'.$msg);
};

sub init {
    my $self = shift;
    # we aren't instantiated when the subscription role would run, so do it
    # here
    TAEB->publisher->subscribe($self);
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
    elsif ($args{body} =~ /^watch/i) {
        my $msg_name = $args{body};
        $msg_name =~ s/^watch\s*//i;
        return "Can't watch $msg_name" if $msg_name eq 'step'
                                       || $msg_name eq 'death'
                                       || $msg_name eq 'save';
        $self->watch_message($msg_name);
        return "Watching message $msg_name";
    }
    elsif ($args{body} =~ /^unwatch/i) {
        my $msg_name = $args{body};
        $msg_name =~ s/^watch\s*//i;
        return "Can't watch $msg_name" if $msg_name eq 'step'
                                       || $msg_name eq 'death'
                                       || $msg_name eq 'save';
        $self->unwatch_message($msg_name);
        return "No longer watching message $msg_name";
    }
    elsif ($args{body} =~ /^watching/i) {
        return join ', ', $self->watching_messages;
    }
}

sub log {
    my $self = shift;
    for (@_) {
        chomp;
        TAEB->debug($_);
    }
}

no Moose;

1;

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

has step => (
    metaclass => 'Counter',
    default => -1,
    trigger => sub {
        my $self = shift;
        my $val = shift;
        $self->set_step(0) if $val < 0;
    }
);

has _watching_messages => (
    metaclass => 'Set::Object',
    lazy => 1,
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
        my $self = shift;
        $self->say(channel => $self->channels,
                   body    => "I received a $msg message with args " .
                              join(', ', @_));
        $self->unwatch_message($msg);
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
    } while ($poe_kernel->get_next_event_time - time < 0
          || ($self->paused && $self->step == 0));

    $self->dec_step;
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

my %responses = (
    who      => sub {
        sprintf "%s (%s %s %s %s)", TAEB->name, TAEB->role, TAEB->race,
                                    TAEB->gender, TAEB->align
    },
    where    => sub {
        sprintf "%s %s", TAEB->current_tile, TAEB->current_level
    },
    inventory => sub {
        my $inv = sprintf "%s", TAEB->inventory;
        $inv =~ s/\n/, /g;
        $inv
    },
    status    => sub {
        join(', ', TAEB->statuses) || 'None'
    },
    map      => sub {
        require App::Nopaste;
        App::Nopaste::nopaste(text => TAEB->vt->as_string("\n"),
                              nick => TAEB->name);
    },
    pause    => sub {
        shift->paused(1);
        TAEB->notify('Paused (IRC)', 0);
        'Paused'
    },
    unpause  => sub {
        shift->paused(0);
        'Unpaused'
    },
    step     => sub {
        my $self = shift;
        my $turns = shift || 1;
        $self->inc_step($turns);
        'Stepping ('.$self->step.')'
    },
    watch    => sub {
        my $self = shift;
        my $msg_name = shift;
        return "Can't watch $msg_name" if $msg_name eq 'step'
                                       || $msg_name eq 'death'
                                       || $msg_name eq 'save';
        $self->watch_message($msg_name);
        "Watching message $msg_name"
    },
    unwatch  => sub {
        my $self = shift;
        my $msg_name = shift;
        return "Can't watch $msg_name" if $msg_name eq 'step'
                                       || $msg_name eq 'death'
                                       || $msg_name eq 'save';
        $self->unwatch_message($msg_name);
        "No longer watching message $msg_name"
    },
    watching => sub {
        join(', ', shift->watching_messages) || 'None'
    },
);

sub said {
    my $self = shift;
    my %args = %{ $_[0] };
    return unless $args{address};

    TAEB->debug("Somebody is talking to us! ($args{who}, $args{body})");
    my ($command, $args) = $args{body} =~ /^(\w+)(?:\s+(.*))?/;
    if (exists $responses{$command}) {
        return $responses{$command}->($self, $args);
    }
    elsif (my $attr = TAEB->senses->meta->get_attribute($command)) {
        my $reader = $attr->get_read_method_ref;
        my $value = $reader->(TAEB->senses);
        $value = '(undef)' if !defined($value);
        return $value;
    }
    else {
        return "Don't know command $command";
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

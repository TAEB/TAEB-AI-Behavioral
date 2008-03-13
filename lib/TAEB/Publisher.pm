#!/usr/bin/env perl
package TAEB::Publisher;
use Moose;

has queued_messages => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] },
);

has delayed_messages => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] },
);

sub update {
    my $self = shift;
    $self->tick_messages;
    $self->send_messages;
}

sub enqueue_message {
    my $self = shift;
    my $msgname = shift;

    TAEB->debug("Queued message $msgname.");

    push @{ $self->queued_messages }, ["msg_$msgname", @_];
}

sub send_messages {
    my $self = shift;
    my @msgs = splice @{ $self->queued_messages };

    for (@msgs) {
        my $msgname = shift @$_;
        TAEB->debug("Dequeueing message $msgname.");

        # this list should not be hardcoded. instead, we should let anything
        # subscribe to messages
        for my $recipient (TAEB->senses, TAEB->inventory, TAEB->spells, TAEB->dungeon->cartographer, TAEB->action, "TAEB::Spoilers::Item::Artifact", "TAEB::Knowledge") {
            next unless $recipient;

            if ($recipient->can('send_message')) {
                $recipient->send_message($msgname, @$_);
            }
            elsif ($recipient->can($msgname)) {
                $recipient->$msgname(@$_)
            }
        }
    }
}

sub delay_message {
    my $self = shift;
    push @{ $self->delayed_messages }, [@_];
}

sub tick_messages {
    my $self = shift;

    for (my $i = 0; $i < @{ $self->delayed_messages }; ) {
        if (--$self->delayed_messages->[$i][0] == 0) {
            my (undef, $msg, @args) = @{ splice @{ $self->delayed_messages }, $i, 1 };
            $self->send_message($msg => @args);
        }
        else {
            ++$i;
        }
    }
}

make_immutable;

1;


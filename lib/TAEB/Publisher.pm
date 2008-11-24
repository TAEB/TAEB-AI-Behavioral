#!/usr/bin/env perl
package TAEB::Publisher;
use TAEB::OO;
use MooseX::AttributeHelper::Set::Object;

has _subscribers => (
    metaclass => 'Set::Object',
    provides  => {
        insert   => 'subscribe',
        remove   => 'unsubscribe',
        elements => 'subscribers',
        size     => 'subscriber_count',
    },
);

has queued_messages => (
    isa     => 'ArrayRef',
    default => sub { [] },
);

has turn_messages => (
    isa     => 'HashRef[ArrayRef]',
    default => sub { {} },
);

before subscribe => sub {
    my $self = shift;
    my $class = shift;
    TAEB->debug("Subscribe: $class");
};
before unsubscribe => sub {
    my $self = shift;
    my $class = shift;
    TAEB->debug("Unsubscribe: $class");
};

sub update {
    my $self = shift;
    $self->turn_messages;
    $self->send_messages;
}

sub enqueue_message {
    my $self = shift;
    my $msgname = shift;

    return unless $msgname;

    TAEB->debug("Queued message $msgname.");

    push @{ $self->queued_messages }, ["msg_$msgname", @_];
}

sub send_messages {
    my $self = shift;

    # if a subscriber generates a message, we want to send it out this turn,
    # not next
    while (@{ $self->queued_messages }) {
        my @msgs = splice @{ $self->queued_messages };

        for (@msgs) {
            my $msgname = shift @$_;
            if (@$_) {
                TAEB->debug("Sending message $msgname with arguments @$_.");
            }
            else {
                TAEB->debug("Sending message $msgname with no arguments.");
            }

            for my $recipient ($self->subscribers) {
                next unless $recipient;

                if ($recipient->can('send_message')) {
                    $recipient->send_message($msgname, @$_);
                }
                if ($recipient->can($msgname)) {
                    $recipient->$msgname(@$_)
                }
            }
        }
    }
}

=head2 get_generic_response Paramhash -> Maybe Str

Don't use this.

=cut

sub get_generic_response {
    my $self = shift;
    my %args = (
        responders => [ $self->responders ],
        @_,
    );

    for (my $i = 0; $i < @{ $args{sets} }; $i += 2) {
        my $matched = 0;
        my @captures;
        my ($re, $name) = @{ $args{sets} }[$i, $i + 1];

        for my $responder (@{ $args{responders} }) {
            if (my $code = $responder->can("$args{method}_$name")) {
                if ($matched ||= @captures = $args{msg} =~ $re) {

                    my $response = $responder->$code(
                        @captures,
                        $args{msg},
                    );
                    next unless defined $response;

                    TAEB->debug(blessed($responder) . " is responding to $name.");
                    return $response;
                }
            }
        }
    }

    for my $responder (grep { defined } @{ $args{responders} }) {
        if (my $code = $responder->can($args{method})) {
            my $response = $responder->$code($args{msg});
            next unless defined $response;

            TAEB->debug(blessed($responder) . " is generically responding to $args{msg}.");
            return $response;
        }
    }

    return;
}

=head2 get_exceptional_response Str -> Maybe Str

This is used to check all messages for exceptions. Such as not having an item
we expected to have.

If no response is given, C<undef> is returned.

=cut

sub get_exceptional_response {
    my $self = shift;
    my $msg  = shift;

    return $self->get_generic_response(
        msg    => $msg,
        sets   => \@TAEB::ScreenScraper::exceptions,
        method => "exception",
    );
}

=head2 get_response Str -> Maybe Str

This is used to check for and get a response to any known prompt on the top
line. Consulted are the personality and action.

If no response is given, C<undef> is returned.

=cut

sub get_response {
    my $self = shift;
    my $line = shift;

    return $self->get_generic_response(
        msg    => $line,
        sets   => \@TAEB::ScreenScraper::prompts,
        method => "respond",
    );
}

=head2 get_location_response Str -> Maybe Tile

This is used to respond to requests to choose a tile (controlled teleport, targeting of ball spells, etc).

If no response is given, C<undef> is returned.

=cut

sub get_location_request {
    my $self = shift;
    my $line = shift;

    return $self->get_generic_response(
        msg    => $line,
        sets   => \@TAEB::ScreenScraper::location_requests,
        method => "location",
    );
}

=head2 send_at_turn turn message args

Send the given message at the given turn.

=cut

sub send_at_turn {
    my $self = shift;
    my $turn = shift;

    push @{ $self->turn_messages->{$turn} }, [@_];
}

=head2 send_in_turns turn message args

Send the given message in the given number of turns.

=cut

sub send_in_turns {
    my $self = shift;
    my $turn = TAEB->turn + shift;
    $self->send_at_turn($turn, @_);
}

sub turn_messages {
    my $self = shift;
    my @messages = splice @{ $self->turn_messages->{TAEB->turn} || [] };

    for (@messages) {
        $self->enqueue_message(@$_);
    }

    delete $self->turn_messages->{TAEB->turn};
}

sub remove_messages {
    my $self = shift;

    I: for (my $i = 0; $i < @{ $self->queued_messages }; ) {
        next if @{ $self->queued_messages->[$i] } < @_;
        for (my $j = 0; $j < @_; ++$j) {
            if ($self->queued_messages->[$i][$j] ne $_[$j]) {
                ++$i;
                next I;
            }
        }
        splice @{ $self->queued_messages }, $i, 1;
    }
}

sub menu_select {
    my $self = shift;
    my $name = shift;
    my $num  = 0;

    return sub {
        my $slot = shift;
        my $item = $_;

        if ($num++ == 0) {
            for my $responder ($self->responders) {
                if (my $method = $responder->can("begin_select_$name")) {
                    $method->($responder);
                }
            }
        }

        for my $responder ($self->responders) {
            if (my $method = $responder->can("select_$name")) {
                my $rt = $method->($responder, $slot, $item);

                return ref($rt) ? $$rt : $rt ? 'all' : undef;
            }
        }

        return undef;
    };
}

sub single_select {
    my $self = shift;
    my $name = shift;

    for my $responder ($self->responders) {
        if (my $method = $responder->can("single_$name")) {
            return $method->($responder, $name);
        }
    }

    return;
}

sub responders { grep { defined } TAEB->personality, TAEB->action }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


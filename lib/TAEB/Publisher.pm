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

my @prompts = (
    qr/^What do you want to write with\?/   => 'write_with',
    qr/^What do you want to dip\?/          => 'dip_what',
    qr/^What do you want to dip into\?/     => 'dip_into_what',
    qr/^What do you want to throw\?/        => 'throw_what',
    qr/^In what direction\?/                => 'what_direction',
    qr/^What do you want to use or apply\?/ => 'apply_what',
    qr/^Lock it\?/                          => 'lock',
    qr/^Unlock it\?/                        => 'unlock',
    qr/^Drink from the (fountain|sink)\?/   => 'drink_from',
    qr/^What do you want to drink\?/        => 'drink_what',
    qr/^What do you want to eat\?/          => 'eat_what',
    qr/^For what do you wish\?/             => 'wish',
    qr/^Really attack (.*?)\?/              => 'really_attack',
    qr/^Call (.*?):/                        => 'call_item',
    qr/^\s*Choose which spell to cast/      => 'which_spell',

    qr/^Dip it into the (fountain|pool of water|water|moat)\?/ => 'dip_into_water',
    qr/^There (?:is|are) (.*?) here; eat (?:it|them)\?/ => 'eat_ground',
    qr/^What do you want to write in the (.*?) here\?/ => 'write_what',
    qr/^What do you want to add to the writing in the (.*?) here\?/ => 'write_what',
    qr/^Do you want to add to the current engraving\?/ => 'add_engraving',
);

=head2 get_response -> Maybe Str

This is used to check for and get a response to any known prompt on the top
line. Consultd are the personality and action.

If no response is given, C<undef> is returned.

=cut

sub get_response {
    my $self = shift;
    my $line = shift;

    for (my $i = 0; $i < @prompts; $i += 2) {
        for my $responder (TAEB->personality, TAEB->action) {
            next unless $responder;

            if (my $code = $responder->can("respond_" . $prompts[$i+1])) {
                if ($line =~ $prompts[$i]) {
                    # pass $1, $2, $3, etc to the action's handler
                    no strict 'refs';
                    my $response = $responder->$code(
                        TAEB->topline,
                        map { $$_ } 1 .. $#+
                    );
                    next unless defined $response;

                    TAEB->debug(blessed($responder) . " is responding to " . $prompts[$i+1].".");
                    # XXX: yes this sets the responded flag on the
                    # action, even if the personality is the one that
                    # responds
                    TAEB->action->responded_this_step(1);
                    return $response;
                }
            }
        }
    }

    return;
}

make_immutable;

1;


#!/usr/bin/perl
package TAEB::Debug::IRC;
use TAEB::OO;
use TAEB::Debug::IRC::Bot;

has bot => (
    isa => 'TAEB::Debug::IRC::Bot',
    is  => 'rw',
);

sub msg_character {
    my $self = shift;
    my ($name, $role, $race, $gender, $align) = @_;

    TAEB->debug("IRC: got a msg_character");
    return unless exists TAEB->config->contents->{IRC};
    my $irc_config = TAEB->config->IRC;
    my $server  = $irc_config->{server}  || 'irc.freenode.net';
    my $port    = $irc_config->{port}    || 6667;
    my $channel = $irc_config->{channel} || '#interhack';

    TAEB->debug("Connecting to $channel on $server:$port with nick $name");
    $self->bot(TAEB::Debug::IRC::Bot->new(
        # Bot::BasicBot settings
        server   => $server,
        port     => $port,
        channels => [$channel],
        nick     => $name,
        no_run   => 1,
    ));
    $self->bot->init;
    $self->bot->run;
}

sub msg_death {
    my $self = shift;
    my ($rank, $score, $end_reason, $death) = @_;
    return unless $self->bot;
    $self->bot->quit_message(sprintf "%s (%s %s %s %s), %d points, %s",
                                     TAEB->name, TAEB->role, TAEB->race,
                                     TAEB->gender, TAEB->align, TAEB->score,
                                     $death || $end_reason);
}

sub msg_save {
    my $self = shift;
    return unless $self->bot;
    $self->bot->quit_message("Saving...");
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

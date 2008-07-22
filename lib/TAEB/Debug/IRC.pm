#!/usr/bin/perl
package TAEB::Debug::IRC;
use TAEB::OO;
use TAEB::Debug::IRC::Bot;

has bot => (
    isa => 'Maybe[TAEB::Debug::IRC::Bot]',
    is  => 'rw',
    default => sub {
        return unless exists TAEB->config->contents->{IRC};
        my $irc_config = TAEB->config->IRC;
        my $server  = $irc_config->{server}  || 'irc.freenode.net';
        my $port    = $irc_config->{port}    || 6667;
        my $channel = $irc_config->{channel} || '#interhack';
        my $name    = $irc_config->{name}    || TAEB->name;

        TAEB->debug("Connecting to $channel on $server:$port with nick $name");
        TAEB::Debug::IRC::Bot->new(
            # Bot::BasicBot settings
            server   => $server,
            port     => $port,
            channels => [$channel],
            nick     => $name,
            no_run   => 1,
        );
    },
);

sub msg_character {
    my $self = shift;
    $self->bot->run if $self->bot;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

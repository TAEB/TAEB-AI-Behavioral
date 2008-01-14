#!/usr/bin/env perl
package TAEB::AI::Personality;
use Moose;

has currently => (
    is => 'rw',
    isa => 'Str',
    default => "?",
    trigger => sub {
        my ($self, $currently) = @_;
        TAEB->info("Currently: $currently.") unless $currently eq '?';
    },
);

has path => (
    is => 'rw',
    isa => 'TAEB::World::Path',
    trigger => sub {
        my ($self, $path) = @_;
        TAEB->info("Current path: @{[$path->path]}.") if $path;
    },
);

=head1 NAME

TAEB::AI::Personality - how TAEB tactically extracts its amulets

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head2 next_action -> STRING

This is the method called by the main TAEB code to get individual commands. It
will be called with a C<$self> which will be your TAEB::AI::Personality object,
and a TAEB object for interacting with the rest of the system (such as for
looking at the map).

It should just return the string to send to NetHack.

Your subclass B<must> override this method.

=cut

sub next_action {
    die "You must override the 'next_action' method in TAEB::AI::Personality.";
}

=head2 institute

This is the method called when TAEB begins using this personality. This is
guaranteed to be called before any calls to next_action.

=cut

sub institute {
}

=head2 send_message Str, *

This will send the message to itself. This is here because
Personality::Behavioral will override it.

=cut

sub send_message {
    my $self = shift;
    my $msgname = shift;

    $self->$msgname(@_)
        if $self->can($msgname);
}

=head2 want_item Item -> Bool

Does TAEB want this item?

=cut

sub want_item {
    my $self = shift;

    $self->pickup(@_);
}

=head2 pickup Item -> Bool

Will TAEB pick up this item? Not by default, no.

=cut

sub pickup { 0 }

=head2 drop Item -> Bool

Will TAEB drop this item? Not by default, no.

=cut

sub drop { 0 }

=head2 msg_powerup Str, *

Received when we've got a powerup-like message. Currently handles C<enhance>.

=cut

sub msg_powerup {
    my $self = shift;
    my $type = shift;

    if ($type eq 'enhance') {
        return "#enhance\n";
    }
}

=head2 enhance Str, Str -> Bool

Callback for enhancing. Receives skill type and current level. Returns whether
we should enhance it or not. Default: YES.

=cut

sub enhance {
    my $self  = shift;
    my $skill = shift;
    my $level = shift;

    return 1;
}

1;


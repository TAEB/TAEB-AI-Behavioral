#!/usr/bin/env perl
package TAEB::AI::Brain;
use Moose;

has taeb => (
    is       => 'rw',
    isa      => 'TAEB',
    weak_ref => 1,
);

=head1 NAME

TAEB::AI::Brain - how TAEB tactically extracts its amulets

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head2 next_action TAEB -> STRING

This is the method called by the main TAEB code to get individual commands.
It will be called with a C<$self> which will be your TAEB::AI::Brain object, and
a TAEB object for interacting with the rest of the system (such as for looking
at the map).

It should just return the string to send to NetHack.

Your subclass B<must> override this method.

=cut

sub next_action {
    die "You must override the 'next_action' method in TAEB::AI::Brain.";
}

=head2 institute TAEB

This is the method called when TAEB begins using this brain. This is guaranteed
to be called before any calls to next_action.

=cut

sub institute {
}

=head2 each_adjacent CODE

This is called for each tile adjacent to TAEB. The coderef will receive three
arguments: the brain object, the TAEB object, and the tile object.

=cut

sub each_adjacent {
    my $self = shift;
    my $code = shift;

    my $taeb = $self->taeb;

    for my $dy (-1 .. 1) {
        for my $dx (-1 .. 1) {
            my $tile = $taeb->current_level->at($dx + $taeb->x, $dy + $taeb->y);
            $code->($self, $taeb, $tile);
        }
    }
}

1;


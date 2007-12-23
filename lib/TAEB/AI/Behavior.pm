#!/usr/bin/env perl
package TAEB::AI::Behavior;
use Moose;

has path => (
    is  => 'rw',
    isa => 'TAEB::World::Path',
    trigger => sub {
        my ($self, $path) = @_;
        my @commands = split '', ($path ? $path->path : '');
        $self->commands(\@commands);
    },
);

has currently => (
    is  => 'rw',
    isa => 'Str',
);

has commands => (
    is  => 'rw',
    isa => 'ArrayRef[Str]',
);

=head2 prepare -> Int

This should do any preparation required for the action it's going to take.
This includes things like pathfinding for Explore.

C<prepare> should return an integer from 0 to 100. The higher the integer, the
higher the urgency of the action.

=cut

sub prepare { 0 }

=head2 next_action -> Str

This should return the command that should be sent to NetHack. Note that
C<prepare> is guaranteed to be called before C<next_action> for any given
action. C<next_action> may not be called at all though. C<next_action> will
not be called if C<prepare> returned 0.

=cut

sub next_action {
    my $self = shift;
    my $action = shift @{ $self->commands };
    if (!defined($action) || $action eq '') {
        TAEB->error("Behavior ".$self->name." returned empty next_action.");
    }
    return $action;
}

=head2 name -> Str

The name of the behavior. This should be unique across behaviors. Just be safe
and don't override this!

=cut

sub name {
    my $self = shift;
    my $pkg = blessed($self) || $self;
    $pkg =~ s/^TAEB::AI::Behavior:://;
    $pkg =~ s/::/_/g;
    return lc $pkg;
}

1;


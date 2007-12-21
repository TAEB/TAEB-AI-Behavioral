#!/usr/bin/env perl
package TAEB::AI::Behavior;
use Moose;

=head2 prepare -> Int

This should do any preparation required for the action it's going to take.
This includes things like pathfinding for Explore.

C<prepare> should return an integer from 0 to 1000. The higher the integer, the
higher the urgency of the action. For example, a FixHunger behavior would
return 900 if Fainting, 700 if Weak, 500 if Hungry, and 200 if not hungry, and
0 if Satiated. It may even have a sliding scale based on its current hunger
value.

=cut

sub prepare { 0 }

=head2 next_action -> Str

This should return the command that should be sent to NetHack. Note that
C<prepare> is guaranteed to be called before C<next_action> for any given
action. C<next_action> may not be called at all though. C<next_action> will
not be called if C<prepare> returned 0.

=cut

sub next_action { }

=head2 currently -> Str

This should return the human-readable "what I'm currently doing" string for
the action being taken. This will be called after C<next_action>.

=cut

sub currently { "?" }

=head2 max_urgency -> Int

This should return the maximum possible urgency for this behavior. This is so
the personality can short-circuit if it finds a high-urgency action.

=cut

sub max_urgency { 1000 }

1;


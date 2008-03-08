#!/usr/bin/env perl
package TAEB::Action;
use Moose;

=head2 done

This is called just before the action is freed, just before the next command
is run.

=cut

sub done { }

make_immutable;

1;


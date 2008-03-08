#!/usr/bin/env perl
package TAEB::Action;
use Moose;

=head2 command

This is the basic command for the action. For example, C<E> for engraving, and
C<#pray> for praying.

=cut

sub command {
    my $class = blessed($_[0]) || $_[0];
    confess "$class must defined a 'command' method.";
}

=head2 run

This is what is called to begin the NetHack command. Usually you don't override
this. Your command should define prompt handlers (C<respond_*> methods) to
continue interaction.

=cut

sub run { shift->command }

=head2 done

This is called just before the action is freed, just before the next command
is run.

=cut

sub done { }

make_immutable;

1;


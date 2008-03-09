#!/usr/bin/env perl
package TAEB::Action;
use Moose;

has responded_this_step => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

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

=head2 new_action Str, Args => Action

This will create a new action with the specified name and arguments. The name
is typically the package name in lower case.

=cut

sub new_action {
    my $self = shift;
    my $name = shift;

    my $package = "TAEB::Action::\L\u$name";
    unless (eval "use $package; 1") {
        die "Unable to load $package: $@";
    }

    return $package->new(@_);
}

make_immutable;

1;


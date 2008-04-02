#!/usr/bin/env perl
package TAEB::Action;
use TAEB::OO;

use TAEB::Action::Apply;
use TAEB::Action::Ascend;
use TAEB::Action::Cast;
use TAEB::Action::Custom;
use TAEB::Action::Descend;
use TAEB::Action::Dip;
use TAEB::Action::Drop;
use TAEB::Action::Eat;
use TAEB::Action::Engrave;
use TAEB::Action::Kick;
use TAEB::Action::Melee;
use TAEB::Action::Move;
use TAEB::Action::Open;
use TAEB::Action::Pay;
use TAEB::Action::Pickup;
use TAEB::Action::Pray;
use TAEB::Action::Quaff;
use TAEB::Action::Read;
use TAEB::Action::Role::Direction;
use TAEB::Action::Role::Item;
use TAEB::Action::Search;
use TAEB::Action::Throw;
use TAEB::Action::Unlock;
use TAEB::Action::Wear;
use TAEB::Action::Wield;
use TAEB::Action::Zap;

has aborted => (
    isa => 'Bool',
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

=head2 post_responses

This is called just after all responses will be queried, but before the
cartographer, senses, messages, etc are done for this step.

=cut

sub post_responses { }

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

    # guess case if all lowercase, otherwise use whatever we've got
    if ($name eq lc $name) {
        $name = ucfirst $name;
    }

    my $package = "TAEB::Action::$name";
    return $package->new(@_);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


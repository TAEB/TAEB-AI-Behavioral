#!/usr/bin/env perl
package TAEB::AI::Behavior;
use TAEB::OO;

has currently => (
    isa => 'Str',
);

has action => (
    isa => 'TAEB::Action',
);

=head2 prepare -> Int

This should do any preparation required for the action it's going to take.
This includes things like pathfinding for Explore.

C<prepare> should return an integer from 0 to 100. The higher the integer, the
higher the urgency of the action.

=cut

sub prepare { 0 }

=head2 do Str, Args -> Action

This will create an Action of the given name, initialized with the given
arguments.

=cut

sub do {
    my $self = shift;
    my $name = shift;

    my $action = TAEB::Action->new_action($name => @_);
    $self->action($action);
}

=head2 name -> Str

The name of the behavior. This should not be overridden.

=cut

sub name {
    my $self = shift;
    my $pkg = blessed($self) || $self;
    $pkg =~ s/^TAEB::AI::Behavior:://;
    return $pkg;
}

=head2 write_elbereth [Bool]

This will do the best it can to write an Elbereth. The optional boolean
specifies whether a depletable method should be used. If it's false, only
methods such as finger-in-dust or Magicbane will be used. If it's true, it
will use the best method it can (starting with wand of fire and going down).

Just call it instead of C<< $self->commands >> and C<< $self->currently >>.

=cut

sub write_elbereth {
    my $self = shift;
    my $best = shift;

    $self->currently("Writing Elbereth.");

    my $item;
    if ($best) {
        $item = TAEB->find_item("wand of fire")
             || TAEB->find_item("wand of lightning")
             || TAEB->find_item("athame")
             || TAEB->find_item("wand of digging")
             || TAEB->find_item("magic marker")
             || '-';
    }
    else {
        $item = TAEB->find_item("athame")
             || '-';
    }

    $self->do(engrave => item => $item);
}

=head2 pickup Item -> Bool

This will be called any time a pick-up menu is invoked. If your behavior knows
how to use items, this is how it can let TAEB know it should pick them up.

=cut

sub pickup { 0 }

=head2 drop Item -> Maybe Bool

This will be called any time a drop menu is invoked. If your behavior knows how
to use items, and when it no longer needs them, this is how it can let TAEB
know it should drop them.

If the return value is undefined, then this behavior doesn't care about the
particular item. If the return value is false, then this item should C<not> be
dropped, even if other behaviors say it should be.

=cut

sub drop { undef }

=head2 if_path Path, String|CODE[, Int] -> Int

If the first argument is undef or a path of length 0, then return 0 to indicate
"I don't want to be run."

If the first argument is defined and is a path of length greater than zero,
then use it as the current path. The behavior gets a "currently" of the second
argument (which may be a coderef -- this is useful it depends on $path being
valid), and return the third argument as the priority (or the default of 50).
This replaces this code:

    if ($path) {
        $self->currently($currently);
        $self->do(move => path => $path);
        return $ok;
    }
    return 0;

with

    $self->if_path($path => $currently, $ok);

=cut

sub if_path {
    my $self      = shift;
    my $path      = shift;
    my $currently = shift;

    return 0 if !defined($path) || length($path->path) == 0;

    $self->do(move => path => $path);

    if (defined $currently) {
        if (ref($currently) eq 'CODE') {
            $self->currently($currently->());
        }
        else {
            $self->currently($currently);
        }
    }

    return @_ ? shift : 50;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

